require_relative 'control_domain'
require_relative 'control'
require_relative 'question'
require_relative 'answer'
require_relative 'answers'

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
    @answers ||= Answers.new

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
      'source-file' => source_file
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

  def get_start_row(version)
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

  def self.from_xlsx(input_file)
    matrix = Matrix.new(
      source_path: input_file
    )

    all_rows = matrix.worksheet.sheet_data.rows

    start_row = matrix.get_start_row(matrix.version)
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

      domain_id = row.control_domain_id
      unless domain_id.nil?

        control_domain = matrix.control_domains[domain_id] ||
                         ControlDomain.new(
                           id: row.control_domain_id,
                           title: row.control_domain_title
                         )

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

        # Store the Control
        control_domain.controls[control_id] = control
      end

      # Store the Question
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

    matrix.answers.metadata = matrix.metadata

    matrix
  end

  def to_control_hash
    {
      'ccm' => {
        'metadata' => metadata.to_hash,
        'control-domains' => control_domains.each_with_object([]) do |(_k, v), acc|
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
end
end
