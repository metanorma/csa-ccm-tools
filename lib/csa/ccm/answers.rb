require_relative 'control_domain'
require_relative 'control'
require_relative 'question'
require_relative 'answer'

module Csa::Ccm

class Answers

  ATTRIBS = %i[
    version answers source_path metadata
  ].freeze

  attr_accessor *ATTRIBS

  def initialize(options = {})
    options.each_pair do |k, v|
      send("#{k}=", v)
    end

    if @source_path
      ccm = YAML.safe_load(File.read(@source_path, encoding: 'UTF-8'))['ccm']
      @answers = ccm['answers'].map { |a| [a['question-id'], Answer.new(a)] }.to_h
      @metadata ||= ccm['metadata']
      @version ||= @metadata['version']
    end

    @answers ||= {}

    self
  end

  def <<(answer)
    @answers[answer.question_id] = answer
  end

  def apply_to(matrix)
    worksheet = matrix.worksheet
    all_rows = worksheet.sheet_data.rows

    start_row = matrix.get_start_row(matrix.version)
    max_row_number = all_rows.length - 1

    (start_row..max_row_number).each do |row_number|
      question_id = worksheet[row_number][2].value

      next unless @answers.key?(question_id)

      answer = @answers[question_id]

      answer_col = case answer.answer
                   when 'yes', true
                     5
                   when 'no', false
                     6
                   when 'NA'
                     7
                   end

      worksheet[row_number][answer_col].change_contents(answer.comment)
    end

    matrix
  end

  def to_hash(skip_comment)
    {
      'ccm' => {
        'metadata' => @metadata.to_hash,
        'answers' => @answers.values.sort.map { |a| a.to_hash(skip_comment) }
      }
    }
  end

  def to_file(filename, skip_comment)
    File.open(filename, 'w') do |file|
      file.write(to_hash(skip_comment).to_yaml)
    end
  end
end

end