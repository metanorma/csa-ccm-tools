module Csa::Ccm

class Control
  ATTRIBS = %i(
    id title specification questions
  )

  attr_accessor *ATTRIBS

  def initialize(options={})
    options.each_pair do |k,v|
      self.send("#{k}=", v)
    end

    @questions ||= {}

    self
  end

  def to_hash
    ATTRIBS.inject({}) do |acc, attrib|
      value = self.send(attrib)

      unless value.nil?

        if attrib == :questions
          value = value.values.map(&:to_hash)
        end

        acc.merge(attrib.to_s => value)
      else
        acc
      end
    end
  end

  def to_yaml
    to_hash.to_yaml
  end

  def to_file(filename)
    File.open(filename,"w") do |file|
      file.write(to_yaml)
    end
  end

end

end