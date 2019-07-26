require_relative "control"

module Csa::Ccm

class ControlDomain
  ATTRIBS = %i(
    id title controls
  )

  attr_accessor *ATTRIBS

  def initialize(options={})
    options.each_pair do |k,v|
      self.send("#{k.to_s.tr('-', '_')}=", v)
    end

    @controls ||= {}

    self
  end

  def to_hash
    ATTRIBS.inject({}) do |acc, attrib|
      value = self.send(attrib)

      unless value.nil?
        if attrib == :controls
          value = value.values.map(&:to_hash)
        end

        acc.merge(attrib.to_s.tr('-', '_') => value)
      else
        acc
      end
    end
  end

  def to_yaml
    to_hash.to_yaml
  end

  def to_file(filename)
    File.open(filename, "w") do |file|
      file.write(to_yaml)
    end
  end

end

end