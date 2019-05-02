require 'spec_helper'

RSpec.describe Csa::Ccm::Cli do
  before(:all) do
    FileUtils.mkdir_p './tmp'
  end

  after(:all) do
    FileUtils.rm_rf './tmp'
    FileUtils.rm_f './caiq-3.0.1.yaml'
    FileUtils.rm_f './resources/csa-caiq-v3.0.1-12-05-2016.yaml'
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
    validate_yaml('./samples/ccm.schema.yaml', './caiq-3.0.1.yaml')
  end

  it 'ccm-yaml 3.0.1 -o ccm-301.yaml' do
    command = %w[ccm-yaml 3.0.1 -o ./tmp/ccm-301.yaml]
    capture_stdout { Csa::Ccm::Cli::Command.start(command) }

    expect(File.exist?("./tmp/ccm-301.yaml")).to be_truthy
    validate_yaml('./samples/ccm.schema.yaml', './tmp/ccm-301.yaml')
  end

  it 'xlsx2yaml ./resources/csa-caiq-v3.0.1-12-05-2016.xlsx' do
    command = %w[xlsx2yaml ./resources/csa-caiq-v3.0.1-12-05-2016.xlsx]
    capture_stdout { Csa::Ccm::Cli::Command.start(command) }

    expect(File.exist?('./resources/csa-caiq-v3.0.1-12-05-2016.yaml')).to be_truthy
    validate_yaml('./samples/ccm.schema.yaml', './resources/csa-caiq-v3.0.1-12-05-2016.yaml')
  end

  it 'xlsx2yaml ./resources/csa-caiq-v3.0.1-12-05-2016.xlsx -o ./tmp/ccm-301-2.yaml' do
    command = %w[xlsx2yaml ./resources/csa-caiq-v3.0.1-12-05-2016.xlsx -o ./tmp/ccm-301-2.yaml]
    capture_stdout { Csa::Ccm::Cli::Command.start(command) }

    expect(File.exist?('./tmp/ccm-301-2.yaml')).to be_truthy
    validate_yaml('./samples/ccm.schema.yaml', './tmp/ccm-301-2.yaml')
  end

  it 'caiq2yaml ./resources/csa-caiq-v3.0.1-09-01-2017.xlsx' do
    command = %w[caiq2yaml ./resources/csa-caiq-v3.0.1-09-01-2017.xlsx -n test -p ./tmp]
    capture_stdout { Csa::Ccm::Cli::Command.start(command) }

    expect(File.exist?('./tmp/test.control.yaml')).to be_truthy
    expect(File.exist?('./tmp/test.answers.yaml')).to be_truthy

    validate_yaml('./samples/ccm.schema.yaml', './tmp/test.control.yaml')
    validate_yaml('./samples/ccm-answers.schema.yaml', './tmp/test.answers.yaml')
  end

  it 'generate-with-answers ./samples/ccm-answers.yaml -o ./tmp/ccm-answers.xlsx' do
    command = %w[generate-with-answers ./samples/ccm-answers.yaml -o ./tmp/ccm-answers.xlsx]
    capture_stdout { Csa::Ccm::Cli::Command.start(command) }

    expect(File.exist?('./tmp/ccm-answers.xlsx')).to be_truthy
    expect(File.size?('./tmp/ccm-answers.xlsx')).to be > 0
  end

  def validate_yaml(schema_path, validatable_path)
    schema = File.read(schema_path, encoding: 'UTF-8')
    validatable = File.read(validatable_path, encoding: 'UTF-8')

    rx = Rx.new(load_core: true)

    schema = rx.make_schema(YAML.load(schema))
    schema.check!(YAML.load(validatable))
  end
end