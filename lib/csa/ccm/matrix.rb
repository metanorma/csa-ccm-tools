require_relative "control_domain"
require_relative "control"
require_relative "question"
require_relative "answer"

module Csa::Ccm

class Matrix
  ATTRIBS = %i(
    version title source_file workbook source_path control_domains answers
  )

  attr_accessor *ATTRIBS

  def initialize(options={})
    options.each_pair do |k,v|
      self.send("#{k}=", v)
    end

    if source_path
      @workbook = RubyXL::Parser.parse(source_path)
    end

    @control_domains ||= {}
    @answers ||= []

    self
  end

  def source_file
    @source_file || File.basename(source_path)
  end

  def worksheet
    workbook.worksheets.first
  end

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
    ATTRIBS = %i(
      control_domain_id control_id question_id control_spec
      question_content answer_yes answer_no answer_na notes
      control_domain_description
    )

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

      # In 3.0.1 2017-09-01, Rows 276 and 277's control ID says "LG-02" but it should be "STA-05" instead.
      @control_id = question_id.split(".").first if question_id
      @control_domain_id = control_id.split("-").first if control_id

      # puts "HERE IN ROW! #{ruby_xl_row.cells.map(&:value)}"

      # puts control_domain_description
      # puts control_id
      # puts question_id

      self
    end

    def control_domain_name
      return nil if control_domain_description.nil?
      name, _, control_name = control_domain_description.split(/(\n)/)
      name
    end

    def control_name
      return nil if control_domain_description.nil?
      name, _, control_name = control_domain_description.split(/(\n)/)
      control_name
    end
  end

  def row(i)
    Row.new(worksheet[i])
  end

  def self.from_xlsx(version, input_file)
    matrix = Matrix.new(
      version: version,
      source_path: input_file
    )

    all_rows = matrix.worksheet.sheet_data.rows
    start_row = 4 # FIXME add some basic logic to calculate it

    last_control_domain = nil
    last_control_id = nil
    last_control_specification = nil

    worksheet = matrix.worksheet

    row_number = start_row
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
            name: row.control_domain_name
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
          name: row.control_name,
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

      answer = 'NA' if row.answer_na
      answer = 'no' if row.answer_no
      answer = 'yes' if row.answer_yes
      answer_note = row.answer_yes || row.answer_no || row.answer_na
      matrix.answers << Answer.new(
          question_id: row.question_id,
          control_id: control_id,
          answer: answer,
          notes: answer_note)
    end

    matrix
  end

  def to_control_hash
    {
      'ccm' => {
        'metadata' => metadata.to_hash,
        'control_domains' => control_domains.inject([]) do |acc, (k, v)|
            acc << v.to_hash
            acc
          end
      }
    }
  end

  def to_answers_hash
    {
      'ccm' => {
        'metadata' => metadata.to_hash,
        'answers' => answers.inject([]) do |acc, v|
          acc << v.to_hash
          acc
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