require 'spec_helper'

RSpec.describe Csa::Ccm::Cli do
	before(:all) do
    FileUtils.mkdir_p './tmp'
  end

  after(:all) do
    FileUtils.rm_rf './tmp'
    FileUtils.rm './caiq-3.0.1.yaml'
    FileUtils.rm './resources/csa-caiq-v3.0.1-12-05-2016.yaml'
  end

  it 'has a version number' do
    expect(Csa::Ccm::Cli::VERSION).not_to be nil
  end

  it 'command properly implemented' do
    allow(Csa::Ccm::Cli::Command).to receive(:run)
  end

  it 'ccm-yaml 3.0.1' do
    command = %w[ccm-yaml 3.0.1]
    capture_stdout { Csa::Ccm::Cli::Command.start(command) }

    expect(File.exist?('./caiq-3.0.1.yaml')).to be_truthy
  end

  it 'ccm-yaml 3.0.1 -o ccm-301.yaml' do
    command = %w[ccm-yaml 3.0.1 -o ./tmp/ccm-301.yaml]
    capture_stdout { Csa::Ccm::Cli::Command.start(command) }

    expect(File.exist?("./tmp/ccm-301.yaml")).to be_truthy
  end

  it 'xlsx2yaml ./resources/csa-caiq-v3.0.1-12-05-2016.xlsx' do
    command = %w[xlsx2yaml ./resources/csa-caiq-v3.0.1-12-05-2016.xlsx]
    capture_stdout { Csa::Ccm::Cli::Command.start(command) }

    expect(File.exist?('./resources/csa-caiq-v3.0.1-12-05-2016.yaml')).to be_truthy
  end

  it 'xlsx2yaml ./resources/csa-caiq-v3.0.1-12-05-2016.xlsx -o ./tmp/ccm-301-2.yaml' do
    command = %w[xlsx2yaml ./resources/csa-caiq-v3.0.1-12-05-2016.xlsx -o ./tmp/ccm-301-2.yaml]
    capture_stdout { Csa::Ccm::Cli::Command.start(command) }

    expect(File.exist?('./tmp/ccm-301-2.yaml')).to be_truthy
  end
end