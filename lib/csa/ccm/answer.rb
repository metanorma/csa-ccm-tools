module Csa::Ccm

class Answer

  ATTRIBS = %i(
    id content
    control-id question-id
    notes
  )

  attr_accessor *ATTRIBS

  def initialize(options={})
    @examples = []
    @notes = []

    # puts "options #{options.inspect}"

    options.each_pair do |k, v|
      next unless v
      case k
      when /^example/
        @examples << v
      when /^note/
        @notes << v
      else
        # puts"Key #{k}"
        key = k.gsub("-", "_")
        self.send("#{key}=", v)
      end
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

  # # entry-status
  # ## Must be one of notValid valid superseded retired
  # def entry_status=(value)
  #   unless %w(notValid valid superseded retired).include?(value)
  #     value = "notValid"
  #   end
  #   @entry_status = value
  # end

end

end