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
      self.send("#{k}=", v)
    end

    self
  end

  def to_hash
    ATTRIBS.inject({}) do |acc, attrib|
      value = self.send(attrib)
      unless value.nil?
        acc.merge(attrib.to_s => value)
      else
        acc
      end
    end
  end
end

end