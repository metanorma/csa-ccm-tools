require_relative "sheet_section"

module Csa::Ccm

class MetadataSection < SheetSection
  attr_accessor :header_row
  attr_accessor :attributes

  GLOSSARY_HEADER_ROW_MATCH = {
    "A" => [nil, "Item", "A"], # "Arabic" uses "A"
    "C" => ["Data Type"],
    "D" => ["Special Instruction"],
    "E" => ["ISO 19135 Class.attribute"],
    "F" => ["Domain"]
  }

  GLOSSARY_ROW_KEY_MAP = {
    "A" => "name",
    "B" => "value",
    "C" => "datatype",
    "D" => "special-instruction",
    "E" => "19135-class-attribute",
    "F" => "value-domain"
  }

  def initialize(rows, options={})
    super
    raise unless self.class.match_header(@rows[0])
    @header_row = @rows[0]
    @body_rows = @rows[1..-1]
    attributes
    self
  end

  def self.match_header(row)
    # puts "row #{row}"
    row.inject(true) do |acc, (key, value)|
      # puts"#{key}, #{value}"
      if GLOSSARY_HEADER_ROW_MATCH[key]
        acc && GLOSSARY_HEADER_ROW_MATCH[key].include?(value)
      else
        acc
      end
    end
  end

  def structure
    GLOSSARY_ROW_KEY_MAP
  end

  def parse_row(row)
    return nil if row.empty?
    attribute = {}

    structure.each_pair do |key, value|
      # puts"#{key}, #{value}, #{row[key]}"
      attribute_key = value
      attribute_value = row[key]
      next if attribute_value.nil?
      attribute[attribute_key] = attribute_value
    end

    # TODO: "Chinese" name is empty!
    key = (attribute["name"] || "(empty)").downcase.split(" ").join("-")

    { key => attribute }
  end

  def attributes
    return @attributes if @attributes

    @attributes = {}
    @body_rows.each do |row|
      result = parse_row(row)
      @attributes.merge!(result) if result
    end
    @attributes
  end

  def to_hash
    {
      "metadata" => attributes
    }
  end

end
end
