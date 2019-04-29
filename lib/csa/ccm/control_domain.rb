require_relative "concept"

module Csa::Ccm

class ControlDomain < Hash

  def add_term(term)
    if self[term.id]
      self[term.id].add_term(term)
    else
      self[term.id] = Control.new(
        id: term.id,
        terms: [term]
      )
    end
  end

  def to_hash
    self.inject({}) do |acc, (id, concept)|
      acc.merge!(id => concept.to_hash)
    end
  end

  def to_file(filename)
    File.open(filename,"w") do |file|
      file.write(to_hash.to_yaml)
    end
  end

end

end