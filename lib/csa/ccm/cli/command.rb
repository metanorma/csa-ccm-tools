
module Csa::Ccm
  module Cli
    class Command < Thor
      desc "fetch CODE", "Fetch Relaton XML for Standard identifier CODE"
      option :type, aliases: :t, required: true, desc: "Type of standard to get bibliographic entry for"
      option :year, aliases: :y, type: :numeric, desc: "Year the standard was published"

      def fetch(code)
        Relaton::Cli.relaton
        say(fetch_document(code, options) || supported_type_message)
      end

    end
  end
end
