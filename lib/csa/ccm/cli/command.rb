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
            UI.say("#{input_file} doesn't exists for #{version} version")
            return
          end

          matrix = Matrix.from_xlsx(version, input_file)

          output_file = options[:output_file] || "caiq-#{version}.yaml"
          matrix.to_control_file(output_file)
        end

        desc "xlsx2yaml XLSX_PATH", "Converting CCM XSLX to YAML"
        option :output_file, aliases: :o, type: :string, desc: "Optional output YAML file. If missed, the input file’s name will be used"

        def xlsx2yaml(input_xlsx_file)
          unless input_xlsx_file
            UI.say("#{input_xlsx_file} file doesn't exists")
            return
          end

          version = input_xlsx_file[/(?<=v)[0-9\.]*(?=-)/] || 'unknown'
          matrix = Matrix.from_xlsx(version, input_xlsx_file)

          output_file = options[:output_file] || input_xlsx_file.gsub('.xlsx', '.yaml')
          matrix.to_control_file(output_file)
        end

        desc "caiq2yaml XLSX_PATH", "Converting a filled CAIQ to YAML"
        option :output_name, aliases: :n, type: :string, desc: "Optional output CAIQ YAML file. If missed, the input file’s name will be used"
        option :output_path, aliases: :p, type: :string, desc: "Optional output directory for result file. If missed pwd will be used"

        def caiq2yaml(input_xlsx_file)
          unless input_xlsx_file
            UI.say("#{input_xlsx_file} file doesn't exists")
            return
          end

          version = input_xlsx_file[/(?<=v)[0-9\.]*(?=-)/] || 'unknown'
          matrix = Matrix.from_xlsx(version, input_xlsx_file)

          base_output_file = options[:output_name] || File.basename(input_xlsx_file.gsub('.xlsx', ''))
          if options[:output_path]
            base_output_file = File.join(options[:output_path], base_output_file)
          end

          control_output_file = "#{base_output_file}.control.yaml"
          answers_output_file = "#{base_output_file}.answers.yaml"

          matrix.to_control_file(control_output_file)
          matrix.to_answers_file(answers_output_file)
        end

        desc "generate-with-answers ANSWERS_YAML", "Writing to the CAIQ XSLX template using YAML"

        def generate_with_answers(answers)
          raise 'Not implemented yet'
        end
      end
    end
  end
end
