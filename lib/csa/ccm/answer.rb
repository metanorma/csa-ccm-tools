module Csa::Ccm

class Answer

  ATTRIBS = %i(
    control_id
    question_id
    answer
    comment
  )

  attr_accessor *ATTRIBS

  def initialize(options={})
    options.each_pair do |k, v|
      send("#{k.to_s.tr('-', '_')}=", v)
    end

    self
  end

  def <=>(other)
    question_id <=> other.question_id
  end

  def to_hash(skip_comment)
    ATTRIBS.inject({}) do |acc, attrib|
      value = send(attrib)
      if value.nil? || (attrib == :comment && skip_comment)
        acc
      else
        acc.merge(attrib.to_s.tr('_', '-') => value)
      end
    end
  end
end

end