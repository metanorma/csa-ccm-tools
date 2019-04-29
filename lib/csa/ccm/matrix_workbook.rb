
require "creek"
require "yaml"
require "pathname"
require_relative "information_sheet"
require_relative "terminology_sheet"

module Csa::Ccm

class MatrixWorkbook
  attr_accessor :workbook
  attr_accessor :version
  attr_accessor :date
  attr_accessor :filename
  attr_accessor :title

  SPECIAL_SHEETS = [
    "Glossary Information",
    "Character Encoding Spreadsheet"
  ]

  def initialize(filepath)
    @filename = filepath
    @workbook = Creek::Book.new(filepath)
    @glossary_info = InformationSheet.new(find_sheet_by_name("Glossary Information"))
    @languages = languages_supported
    self
  end

  def languages_supported
    @workbook.sheets.map(&:name).reject! do |name|
      SPECIAL_SHEETS.include?(name)
    end
  end

  def language_sheet(lang)
    raise unless @languages.include?(lang)
    TerminologySheet.new(find_sheet_by_name(lang))
  end

  def find_sheet_by_name(sheet_name)
    @workbook.sheets.detect do |sheet|
      sheet.name == sheet_name
    end
  end

  def write_glossary_info
    glossary_info_fn = Pathname.new(@filename).sub_ext(".yaml")
    File.open(glossary_info_fn,"w") do |file|
      file.write(glossary_info.to_yaml)
    end
  end
end
end
