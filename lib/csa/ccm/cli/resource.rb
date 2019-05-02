require 'yaml'

require_relative '../../../ext/string'

module Csa
  module Ccm
    module Cli
      class Resource
        def self.root_gem
          Pathname.new(__dir__).join('..', '..', '..', '..')
        end

        def self.lookup_version(version)
          Dir["#{root_gem}/resources/**/*v#{version}*.xlsx"]
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