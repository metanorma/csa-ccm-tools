require 'rake'
require 'thor'

require_relative 'ui'
require_relative '../cli'

module Csa
  module Ccm
    module Cli
      class Command < Thor
        desc 'ccm-yaml VERSION', 'Generating a machine-readable CCM/CAIQ'
        option :output_file, aliases: :o, type: :string, desc: 'Optional output YAML file. If missed, the input file’s name will be used'

        def ccm_yaml(version)
          input_files = Resource.lookup_version(version)

          unless input_files || !input_files.empty?
            UI.say("No file found for #{version} version")
            return
          end

          input_file = input_files.first

          unless File.exist? input_file
            UI.say('No file found for version')
            return
          end

          matrix = Matrix.from_xlsx(version, input_file)

          output_file = options[:output_file] || "caiq-#{version}.yaml"
          matrix.to_file(output_file)
        end

        desc "xlsx2yaml XSLT_PATH", "Converting CCM XSLX to YAML"
        option :output_file, aliases: :o, type: :string, desc: "Optional output YAML file. If missed, the input file’s name will be used"

        def xlsx2yaml(xslt_path)
          raise 'Not implemented yet'
        end

        desc "caiq2yaml XSLT_PATH", "Converting a filled CAIQ to YAML"
        option :output_name, aliases: :n, type: :string, desc: "Optional output CAIQ YAML file. If missed, the input file’s name will be used"
        option :output_path, aliases: :p, type: :string, desc: "Optional output directory for result file. If missed pwd will be used"

        def caiq2yaml(xslt_path)
          # if xslt_path.nil?
          #   puts 'Error: no filepath given as first argument.'
          #   exit 1
          # end

          # if Pathname.new(xslt_path).extname != ".xlsx"
          #   puts 'Error: filepath given must have extension .xlsx.'
          #   exit 1
          # end

          # workbook = Csa::Ccm::MatrixWorkbook.new(xslt_path)
          # workbook.glossary_info.metadata_section.structure
          # workbook.glossary_info.metadata_section.attributes

          # languages = {}

          # workbook.languages_supported.map do |lang|
          #   puts "************** WORKING ON LANGUAGE (#{lang})"
          #   sheet = workbook.language_sheet(lang)
          #   termsec = sheet.terms_section
          #   languages[sheet.language_code] = termsec.terms
          # end

          # collection = Csa::Ccm::ControlDomain.new

          # languages.each_pair do |lang, terms|
          #   terms.each do |term|
          #     collection.add_term(term)
          #   end
          # end

          # # collection[1206].inspect

          # # FIXME use  instea output dir
          # output_dir = options[:output_path] || Dir.pwd
          # output_file = options[:output_name] || File.join(output_dir, Pathname.new(filepath).basename.sub_ext(".yaml"))

          # collection.to_file(output_file)

          # collection_output_dir = File.join(output_dir, "concepts")

          # FileUtils.mkdir_p(collection_output_dir)

          # collection.keys.each do |id|
          #   collection[id].to_file(File.join(collection_output_dir, "concept-#{id}.yaml"))
          # end

          # french = workbook.language_sheet("French")
          # french.sections[3].structure
          # french.sections[3].terms

          # english = workbook.language_sheet("English")
          # english.terms_section
          # english.terms_section.terms

          #pry.binding
        end

        desc "generate-with-answers ANSWERS_YAML", "Writing to the CAIQ XSLX template using YAML"

        def generate_with_answers(answers)
          raise 'Not implemented yet'
        end
      end
    end
  end
end
