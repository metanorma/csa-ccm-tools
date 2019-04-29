#!/usr/bin/env ruby

require 'creek'
require 'pp'
require 'pry'
require_relative 'lib/term_workbook'
require_relative 'lib/concept_collection'

filepath = './csa-ccm.xlsx'
workbook = MatrixWorkbook.new(filepath)
workbook.glossary_info.metadata_section.structure
workbook.glossary_info.metadata_section.attributes

languages = {}

workbook.languages_supported.map do |lang|
  puts "******* WORKING ON LANGUAGE (#{lang})"
  sheet = workbook.language_sheet(lang)
  termsec = sheet.terms_section
  languages[sheet.language_code] = termsec.terms
end

collection = ControlDomain.new

languages.each_pair do |lang, terms|
  terms.each do |term|
    collection.add_term(term)
  end
end

collection.to_file("csa-ccm.yaml")

collection.keys.each do |id|
  collection[id].to_file("concepts/concept-#{id}.yaml")
end


# french = workbook.language_sheet("French")
# french.sections[3].structure
# french.sections[3].terms

# english = workbook.language_sheet("English")
# english.terms_section
# english.terms_section.terms

#pry.binding
