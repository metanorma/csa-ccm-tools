require 'spec_helper'

RSpec.describe Csa::Ccm::Cli do
  it 'has a version number' do
    expect(Csa::Ccm::Cli::VERSION).not_to be nil
  end

  it 'ccm-yaml 3.0.1 -o ccm-301.yaml' do
    allow(Csa::Ccm::Cli::Command).to receive(:run)

    FileUtils.mkdir_p './tmp'

    command = %w[ccm-yaml 3.0.1 -o ./tmp/ccm-301.yaml]
    capture_stdout { Csa::Ccm::Cli::Command.start(command) }

    expect(File.exist?("./tmp/ccm-301.yaml")).to be_truthy
  end
end