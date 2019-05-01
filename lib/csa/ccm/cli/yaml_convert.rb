require 'rubyXL'
require 'yaml'

require_relative '../../../ext/string'

module Csa
  module Ccm
    module Cli
      class YamlConvert
        def self.root_gem
          Pathname.new(__dir__).join('..', '..', '..', '..')
        end

        def self.lookup_xlsx(version)
          Dir["#{root_gem}/resources/**/*v#{version}*.xlsx"]
        end

        def self.from_ccm(version, input_file)
          workbook = RubyXL::Parser.parse(input_file)
          worksheet = workbook.worksheets[0]

          title = worksheet[0][2].value

          result = {
            'ccm' => {
              'metadata' => {
                'version' => version,
                'title' => title,
                'source-file' => File.basename(input_file)
              }
            }
          }

          control_domains = {}
          start_row = 4 # FIXME add some basic logic to calculate it

          last_control_domain = nil
          last_control_id = nil
          last_control_specification = nil
          last_question_value = nil

          (start_row..worksheet.sheet_data.rows.length - 1).each { |i|
            question_id = worksheet[i]['C'.to_xls_col].value
            next unless question_id

            last_control_domain = control_domain = worksheet[i]['A'.to_xls_col].value || last_control_domain
            last_control_id = control_id = worksheet[i]['B'.to_xls_col].value || last_control_id
            last_control_specification = control_specification = worksheet[i]['D'.to_xls_col].value || last_control_specification
            last_question_value = question_value = worksheet[i]['E'.to_xls_col].value || last_question_value

            next unless control_domain || control_id

            control_domain_name, _, control_name = control_domain.split(/(\n)/)
            control_domain_id = control_id.split('-')[0]

            control_domain = control_domains[control_domain_id] ||= {
              'id' => control_domain_id,
              'name' => control_domain_name,
              'controls' => {}
            }

            control = control_domain['controls'][control_id] ||= {
              'id' => control_id,
              'name' => control_name,
              'specification' => control_specification,
              'questions' => []
            }

            control['questions'] << { 'id' => question_id, 'content' => question_value }

            puts control['questions']
          }

          control_domains.each do |_, value|
            value['controls'] = value['controls'].values
          end

          result['ccm']['control-domains'] = control_domains.values

          result
        end

        def self.from_xlsx(xslt_path)
          raise 'Not implemented yet'
        end

        def from_caiq(xslt_path, output_name, output_path)
          raise 'Not implemented yet'
        end

        def self.to_file(hash, output_file)
          File.open(output_file, 'w') { |f| f.write hash.to_yaml(line_width: 9999) }
        rescue Errno::ENOENT => e
          UI.say("Cannot write result to #{output_file} because: #{e.message}")
        end
      end
    end
  end
end