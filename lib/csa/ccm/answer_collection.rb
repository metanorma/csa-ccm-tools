require_relative 'answer'

module Csa::Ccm

class AnswerCollection

  ATTRIBS = %i[
    version answers source_path metadata
  ].freeze

  attr_accessor *ATTRIBS

  def initialize(options = {})
    options.each_pair do |k, v|
      send("#{k}=", v)
    end

    @answers ||= {}

    self
  end

  def self.from_yaml(filename)
    ccm = YAML.safe_load(File.read(filename, encoding: 'UTF-8'))['ccm']
    answers = ccm['answers'].map { |a| [a['question-id'], Answer.new(a)] }.to_h
    metadata = ccm['metadata']
    version = metadata['version']

    self.new(
      answers: answers,
      metadata: metadata,
      version: version,
      source_path: filename
    )
  end

  def <<(answer)
    @answers[answer.question_id] = answer
  end

  # TODO: This will go away if we inherit directly from Hash
  def [](question_id)
    @answers[question_id]
  end

  def to_hash(skip_comment = true)
    {
      'ccm' => {
        'metadata' => @metadata.to_hash,
        'answers' => @answers.values.sort.map { |a| a.to_hash(skip_comment) }
      }
    }
  end

  def to_yaml(skip_comment = true)
    to_hash(skip_comment).to_yaml
  end

  def to_file(filename, skip_comment = true)
    File.open(filename, 'w') do |file|
      file.write(to_yaml)
    end
  end
end

end