require_relative 'control_domain'
require_relative 'control'
require_relative 'question'
require_relative 'answer'

require 'rubyXL'
require 'rubyXL/convenience_methods/cell'
require 'rubyXL/convenience_methods/workbook'
require 'rubyXL/convenience_methods/worksheet'

module Csa::Ccm

class Matrix

  ATTRIBS = %i[
    version title source_file workbook source_path control_domains answers
  ].freeze

  attr_accessor *ATTRIBS

  def initialize(options = {})
    options.each_pair do |k, v|
      send("#{k}=", v)
    end

    if source_path
      @workbook = RubyXL::Parser.parse(source_path)

      parse_version if version.nil?
    end

    @control_domains ||= {}
    @answers ||= []

    self
  end

  def source_file
    @source_file || File.basename(source_path)
  end

  def parse_version
    title_prefix = 'consensus assessments initiative questionnaire v'
    first_row = workbook[0][0]

    if first_row[2].value.downcase.start_with? title_prefix # version v3.0.1
      self.version = first_row[2].value.downcase[title_prefix.length..-1]
    elsif first_row[0].value.downcase.start_with? title_prefix # version v1.1
      self.version = first_row[0].value.downcase[title_prefix.length..-1]
    else # version 1.0
      self.version = workbook[1][0][0].value[/(?<=Version )(\d+\.?)+(?= \()/]
    end
  end

  def worksheet
    workbook.worksheets.first
  end

  attr_reader :workbook

  def title
    worksheet = workbook.worksheets.first
    worksheet[0][2].value
  end

  def metadata
    {
      'version' => version,
      'title' => title,
      'source_file' => source_file
    }
  end

  class Row
    ATTRIBS = %i[
      control_domain_id control_id question_id control_spec
      question_content answer_yes answer_no answer_na comment
      control_domain_description
    ].freeze

    attr_accessor *ATTRIBS

    def initialize(ruby_xl_row)
      @control_domain_description = ruby_xl_row[0].value
      @control_id = ruby_xl_row[1].value
      @question_id = ruby_xl_row[2].value
      @control_spec = ruby_xl_row[3].value
      @question_content = ruby_xl_row[4].value
      @answer_yes = ruby_xl_row[5].value
      @answer_no = ruby_xl_row[6].value
      @answer_na = ruby_xl_row[7].value
      @comment = ruby_xl_row[8].value

      # In 3.0.1 2017-09-01, question_id for "AIS-02.2" is listed as "AIS- 02.2"
      %w[control_id question_id].each do |field|
        if val = send(field)
          send("#{field}=", val.gsub(/\s/, ''))
        end
      end

      # In 3.0.1 2017-09-01, Rows 276 and 277's control ID says "LG-02" but it should be "STA-05" instead.
      if @control_id.nil? && @question_id
        @control_id = @question_id.split('.').first
      end

      @control_domain_id = control_id.split('-').first if @control_id

      # puts "HERE IN ROW! #{ruby_xl_row.cells.map(&:value)}"

      # puts control_domain_description
      # puts control_id
      # puts question_id

      self
    end

    def control_domain_title
      return nil if control_domain_description.nil?

      name, = control_domain_description.split(/(\n)/)
      name
    end

    def control_title
      return nil if control_domain_description.nil?

      _, _, control_title = control_domain_description.split(/(\n)/)
      control_title
    end
  end

  def row(i)
    Row.new(worksheet[i])
  end

  def self.get_start_row(version)
    case version
    when '1.0'
      2
    when '1.1'
      3
    else
      # '3.0.1' and assume beyond
      4
    end
  end

  def self.version_from_filepath(input_file)
    input_file[/(?<=v)[0-9\.]*(?=-)/] || 'unknown'
  end

  def self.from_xlsx(input_file)
    matrix = Matrix.new(
      source_path: input_file
    )

    all_rows = matrix.worksheet.sheet_data.rows

    start_row = get_start_row(matrix.version)
    max_row_number = all_rows.length - 1

    # We loop over all Questions
    (start_row..max_row_number).each do |row_number|
      # puts "looping row #{row_number}"
      row = matrix.row(row_number)
      # Skip row if there is no question-id
      # puts"row #{row.question_id}"
      # require 'pry'
      # binding.pry
      next if row.question_id.nil?

      # puts"domain_id #{row.control_domain_id}"

      domain_id = row.control_domain_id
      unless domain_id.nil?

        control_domain = matrix.control_domains[domain_id] ||
                         ControlDomain.new(
                           id: row.control_domain_id,
                           title: row.control_domain_title
                         )

        # puts"control_domain #{control_domain.to_hash}"

        # Store the Control Domain
        matrix.control_domains[domain_id] = control_domain
      end

      control_id = row.control_id
      unless control_id.nil?

        control_domain = matrix.control_domains[domain_id]
        control = control_domain.controls[control_id] || Control.new(
          id: row.control_id,
          title: row.control_title,
          specification: row.control_spec
        )

        # puts"control #{control.to_hash}"
        # Store the Control
        control_domain.controls[control_id] = control
      end

      question = matrix.control_domains[domain_id].controls[control_id]
      # Store the Question
      # putsquestion.to_hash
      control.questions[row.question_id] = Question.new(id: row.question_id, content: row.question_content)

      answer = if row.answer_na
                 'NA'
               elsif row.answer_no
                 'no'
               elsif row.answer_yes
                 'yes'
      end

      matrix.answers << Answer.new(
        question_id: row.question_id,
        control_id: control_id,
        answer: answer,
        comment: row.comment
      )
    end

    matrix
  end

  def self.fill_answers(answers_yaml_path, template_xslt_path, output_xslt_path)
    ccm = YAML.safe_load(File.read(answers_yaml_path, encoding: 'UTF-8'))['ccm']
    answers = ccm['answers']
    answers_hash = Hash[*answers.collect { |a| [a['question-id'], a] }.flatten]
    answers_version = ccm['metadata']['version']
    template_version = version_from_filepath(template_xslt_path)

    unless template_version == answers_version
      raise "Template XLSX & answers YAML version missmatch #{template_version} vs. #{answers_version}"
    end

    matrix = Matrix.new(
      version: template_version,
      source_path: template_xslt_path
    )

    worksheet = matrix.worksheet
    all_rows = worksheet.sheet_data.rows

    start_row = get_start_row(matrix.version)
    max_row_number = all_rows.length - 1

    (start_row..max_row_number).each do |row_number|
      question_id = worksheet[row_number][2].value

      next unless answers_hash.key?(question_id)

      answer = answers_hash[question_id]
      answer_value = answer['answer']

      answer_col = case answer_value
                   when 'yes', true
                     5
                   when 'no', false
                     6
                   when 'NA'
                     7
                   end

      worksheet[row_number][answer_col].change_contents(answer['notes'])
    end

    matrix.workbook.write(output_xslt_path)
    worksheet
  end

  def to_control_hash
    {
      'ccm' => {
        'metadata' => metadata.to_hash,
        'control_domains' => control_domains.each_with_object([]) do |(_k, v), acc|
                               acc << v.to_hash
                             end
      }
    }
  end

  def to_answers_hash
    {
      'ccm' => {
        'metadata' => metadata.to_hash,
        'answers' => answers.each_with_object([]) do |v, acc|
                       acc << v.to_hash
                     end
      }
    }
  end

  def to_control_file(filename)
    File.open(filename, 'w') do |file|
      file.write(to_control_hash.to_yaml)
    end
  end

  def to_answers_file(filename)
    File.open(filename, 'w') do |file|
      file.write(to_answers_hash.to_yaml)
    end
  end
end
end
