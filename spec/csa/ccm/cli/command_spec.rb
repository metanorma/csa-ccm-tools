require 'spec_helper'
require 'tempfile'

RSpec.describe Csa::Ccm::Cli do
  gem_root = Dir.pwd
  ccm_schema = "#{gem_root}/samples/ccm.schema.yaml"
  answers_schema = "#{gem_root}/samples/ccm-answers.schema.yaml"

  let(:tmpdir) { Dir.mktmpdir }

  it 'csa-ccm has a version number' do
    expect(Csa::Ccm::Cli::VERSION).not_to be nil
  end

  it 'cli command properly implemented' do
    allow(Csa::Ccm::Cli::Command).to receive(:run)
  end

  it 'ccm-yaml 3.0.1 -o' do
    output_path = "#{tmpdir}/ccm-301.yaml"
    command = %W[ccm-yaml 3.0.1 -o #{output_path}]
    capture_stdout { Csa::Ccm::Cli::Command.start(command) }

    expect(File.exist?(output_path)).to be_truthy
    validate_yaml(ccm_schema, output_path)
  end

  it 'ccm-yaml missing version' do
    caiq_version = '1.2.3'
    command = %W[ccm-yaml #{caiq_version}]
    output = capture_stdout { Csa::Ccm::Cli::Command.start(command) }

    expect(output).to include("No file found for #{caiq_version} version")
  end


  it 'ccm-yaml 3.0.1' do
    Dir.chdir tmpdir do
      default_output_path = "./caiq-3.0.1.yaml"
      command = %w[ccm-yaml 3.0.1]
      capture_stdout { Csa::Ccm::Cli::Command.start(command) }

      expect(File.exist?(default_output_path)).to be_truthy
      validate_yaml(ccm_schema, default_output_path)
    end
  end

  it 'xlsx2yaml xlsx' do
    default_output_path = "#{tmpdir}/csa-caiq.yaml"
    input_xlsx = "#{tmpdir}/csa-caiq.xlsx"
    FileUtils.cp "#{gem_root}/resources/csa-caiq-v3.0.1-12-05-2016.xlsx", input_xlsx

    command = %W[xlsx2yaml #{input_xlsx}]
    capture_stdout { Csa::Ccm::Cli::Command.start(command) }

    expect(File.exist?(default_output_path)).to be_truthy
    validate_yaml(ccm_schema, default_output_path)
  end

  it 'xlsx2yaml xlsx -o' do
    output_path = "#{tmpdir}/ccm-301-2.yaml"
    command = %W[xlsx2yaml ./resources/csa-caiq-v3.0.1-09-01-2017.xlsx -o #{output_path}]
    capture_stdout { Csa::Ccm::Cli::Command.start(command) }

    expect(File.exist?(output_path)).to be_truthy
    validate_yaml(ccm_schema, output_path)
  end

  it 'caiq2yaml xlsx' do
    Dir.chdir tmpdir do
      output_answers_path = "./csa-caiq-v3.0.1-12-05-2016.answers.yaml"
      output_control_path = "./csa-caiq-v3.0.1-12-05-2016.control.yaml"
      input_xlsx = "#{gem_root}/resources/csa-caiq-v3.0.1-12-05-2016.xlsx"
      FileUtils.cp input_xlsx, tmpdir

      command = %W[caiq2yaml #{input_xlsx}]
      capture_stdout { Csa::Ccm::Cli::Command.start(command) }

      expect(File.exist?(output_control_path)).to be_truthy
      expect(File.exist?(output_answers_path)).to be_truthy

      validate_yaml(ccm_schema, output_control_path)
      validate_yaml(answers_schema, output_answers_path)
    end
  end

  it 'caiq2yaml xlsx -n' do
    Dir.chdir tmpdir do
      output_name = "test"
      output_answers_path = "#{tmpdir}/#{output_name}.answers.yaml"
      output_control_path = "#{tmpdir}/#{output_name}.control.yaml"
      input_xlsx = "#{gem_root}/resources/csa-caiq-v3.0.1-09-01-2017.xlsx"
      FileUtils.cp input_xlsx, tmpdir

      command = %W[caiq2yaml #{input_xlsx} -n #{output_name}]
      capture_stdout { Csa::Ccm::Cli::Command.start(command) }

      expect(File.exist?(output_control_path)).to be_truthy
      expect(File.exist?(output_answers_path)).to be_truthy

      validate_yaml(ccm_schema, output_control_path)
      validate_yaml(answers_schema, output_answers_path)
    end
  end

  it 'caiq2yaml xlsx -p' do
    output_name = "csa-caiq-v3.0.1-12-05-2016"
    output_answers_path = "#{tmpdir}/#{output_name}.answers.yaml"
    output_control_path = "#{tmpdir}/#{output_name}.control.yaml"
    input_xlsx = "#{gem_root}/resources/#{output_name}.xlsx"

    command = %W[caiq2yaml #{input_xlsx} -p #{tmpdir}]
    capture_stdout { Csa::Ccm::Cli::Command.start(command) }

    expect(File.exist?(output_control_path)).to be_truthy
    expect(File.exist?(output_answers_path)).to be_truthy

    validate_yaml(ccm_schema, output_control_path)
    validate_yaml(answers_schema, output_answers_path)
  end

  it 'caiq2yaml xlsx -s' do
    Dir.chdir tmpdir do
      output_name = "csa-caiq-v3.0.1-09-01-2017-filled"
      output_answers_path = "#{tmpdir}/#{output_name}.answers.yaml"
      output_control_path = "#{tmpdir}/#{output_name}.control.yaml"
      input_xlsx = "#{gem_root}/resources/#{output_name}.xlsx"
      FileUtils.cp input_xlsx, tmpdir

      command = %W[caiq2yaml #{input_xlsx} -s true]
      capture_stdout { Csa::Ccm::Cli::Command.start(command) }

      expect(File.exist?(output_control_path)).to be_truthy
      expect(File.exist?(output_answers_path)).to be_truthy

      validate_yaml(ccm_schema, output_control_path)
      validate_yaml(answers_schema, output_answers_path)

      expect(skip_comments?(output_answers_path)).to be_truthy
    end
  end

  it 'caiq2yaml xlsx -n -p' do
    output_name = "result"
    output_answers_path = "#{tmpdir}/#{output_name}.answers.yaml"
    output_control_path = "#{tmpdir}/#{output_name}.control.yaml"

    command = %W[caiq2yaml ./resources/csa-caiq-v3.0.1-09-01-2017.xlsx -n #{output_name} -p #{tmpdir}]
    capture_stdout { Csa::Ccm::Cli::Command.start(command) }

    expect(File.exist?(output_control_path)).to be_truthy
    expect(File.exist?(output_answers_path)).to be_truthy

    validate_yaml(ccm_schema, output_control_path)
    validate_yaml(answers_schema, output_answers_path)
  end

  it 'generate-with-answers yaml' do
    command = %w[generate-with-answers samples/ccm-answers.yaml]
    capture_stdout { Csa::Ccm::Cli::Command.start(command) }

    expect(File.exist?('samples/ccm-answers.xlsx')).to be_truthy
    expect(File.size?('samples/ccm-answers.xlsx')).to be > 0
  end

  it 'generate-with-answers yaml -o' do
    command = %W[generate-with-answers ./samples/ccm-answers.yaml -o #{tmpdir}/ccm-answers.xlsx]
    capture_stdout { Csa::Ccm::Cli::Command.start(command) }

    expect(File.exist?("#{tmpdir}/ccm-answers.xlsx")).to be_truthy
    expect(File.size?("#{tmpdir}/ccm-answers.xlsx")).to be > 0
  end

  it 'generate-with-answers yaml -o -r' do
    command = %W[generate-with-answers ./samples/ccm-answers.yaml -r 3.0.1 -o #{tmpdir}/ccm-answers.xlsx]
    capture_stdout { Csa::Ccm::Cli::Command.start(command) }

    expect(File.exist?("#{tmpdir}/ccm-answers.xlsx")).to be_truthy
    expect(File.size?("#{tmpdir}/ccm-answers.xlsx")).to be > 0
  end

  it 'generate-with-answers yaml -o -t' do
    command = %W[generate-with-answers ./samples/ccm-answers.yaml -t ./resources/csa-caiq-v3.0.1-12-05-2016.xlsx -o #{tmpdir}/ccm-answers.xlsx]
    capture_stdout { Csa::Ccm::Cli::Command.start(command) }

    expect(File.exist?("#{tmpdir}/ccm-answers.xlsx")).to be_truthy
    expect(File.size?("#{tmpdir}/ccm-answers.xlsx")).to be > 0
  end

  it 'generate-with-answers yaml missing version' do
    caiq_version = '1.2.3'
    command = %W[generate-with-answers ./samples/ccm-answers.yaml -r #{caiq_version} -o #{tmpdir}/ccm-answers.xlsx]
    output = capture_stdout { Csa::Ccm::Cli::Command.start(command) }

    expect(output).to include("No file found for #{caiq_version} version")
  end

  it 'generate-with-answers yaml not exists' do
    caiq_version = '1.2.3'
    command = %W[generate-with-answers missing.yaml -o #{tmpdir}/ccm-answers.xlsx]
    output = capture_stdout { Csa::Ccm::Cli::Command.start(command) }

    expect(output).to include("file doesn't exists")
  end

  def validate_yaml(schema_path, validatable_path)
    schema = File.read(schema_path, encoding: 'UTF-8')
    validatable = File.read(validatable_path, encoding: 'UTF-8')

    rx = Rx.new(load_core: true)

    schema = rx.make_schema(YAML.load(schema))
    schema.check!(YAML.load(validatable))
  end

  def skip_comments?(output_answers_path)
    output_answers_file = File.read(output_answers_path, encoding: 'UTF-8')
    yml = YAML.load(output_answers_file)
    skipped = true

    yml["ccm"]["answers"].each do |ans|
      if ans.has_key?("comment")
        skipped = false
      end
    end

    skipped
  end
end