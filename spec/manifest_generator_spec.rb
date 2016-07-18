require 'spec_helper'

describe BoshManifestGenerator::ManifestGenerator do
  describe 'Parse metadata' do
    let(:generator) do
      BoshManifestGenerator::ManifestGenerator.new('/tmp')
    end
    it 'returns parsed yaml file' do
      generator.metadata_file = File.expand_path('metadata.yml',
                                                 File.dirname(__FILE__))
      expect(generator.metadata).to include(
        'meta' => {
          'name' => 'idefixprod', 'availability_zone' => 'us-east-1a',
          'ip_range' => '10.36.1.0/24',
          'gateway_ip' => '10.36.1.1',
          'dns' => ['10.36.0.2'],
          'subnet' => 'subnet-e56424bc',
          'bosh_ip' => '10.36.1.6',
          'aws' => {
            'account_id' => '123456'
          }
        }
      )
    end
    it 'returns account_id' do
      generator.metadata_file = File.expand_path('metadata.yml',
                                                 File.dirname(__FILE__))
      expect(generator.account_id).to eq('123456')
    end

    it 'returns vault prefix based on account_id' do
      generator.metadata_file = File.expand_path('metadata.yml',
                                                 File.dirname(__FILE__))
      expect(generator.vault_prefix).to eq('secret/aws/123456/bosh')
    end

    it 'returns vault prefix if account_id and vaultdeployment are set in metadata file' do
      generator.metadata_file = File.expand_path('metadata-vaultdeployment.yml',
                                                 File.dirname(__FILE__))
      expect(generator.vault_prefix).to eq('secret/aws/123456/foo')
    end

    it 'returns vault prefix if value is set.' do
      generator = BoshManifestGenerator::ManifestGenerator
                  .new(nil, vault_prefix: 'secret/bosh/test/')
      expect(generator.vault_prefix).to eq('secret/bosh/test/')
    end

    it 'returns vault with token' do
      ENV['VAULT_ADDR'] = 'http://127.0.0.1:8200'
      generator.vault_token_file = File.expand_path('vault_token',
                                                    File.dirname(__FILE__))
      expect(generator.vault).to be_a_kind_of(Vault::Client)
    end
  end
  describe 'connect to vault' do
    let(:vault) do
      instance_double(Vault::Client)
    end
    let(:generator) do
      BoshManifestGenerator::ManifestGenerator.new('/tmp',
                                                   vault: vault)
    end

    it 'gets value from vault.' do
      generator.metadata_file = File.expand_path('metadata.yml',
                                                 File.dirname(__FILE__))
      logical = instance_double(Vault::Logical)
      secret = instance_double(Vault::Secret)
      expect(vault).to receive(:logical).and_return(logical)
      expect(logical).to receive(:read)
        .with('secret/aws/123456/bosh/foo/bar').and_return(secret)
      expect(secret).to receive(:data)
        .and_return(value: 'test')
      expect(generator.p('foo.bar')).to eq('test')
    end

    it 'stores manifest file' do
      @tmp_dir = File.join(File.dirname(__FILE__), 'tmp')
      FileUtils.mkdir_p(@tmp_dir)
      generator.metadata_file = File.expand_path('metadata.yml',
                                                 File.dirname(__FILE__))
      logical = instance_double(Vault::Logical)
      secret = instance_double(Vault::Secret)
      expect(vault).to receive(:logical).and_return(logical)
      expect(logical).to receive(:read)
        .with('secret/aws/123456/bosh/foo/bar').and_return(secret)
      expect(secret).to receive(:data)
        .and_return(value: 'test')
      generator.render(
        File.expand_path('manifest_tmpl.yml.erb', File.dirname(__FILE__)),
        "#{@tmp_dir}/manifest.yml")
      expect(File.exist?("#{@tmp_dir}/manifest.yml")).to be_truthy
      FileUtils.rm_rf(@tmp_dir)
    end

    it 'do not show passwords' do
      @tmp_dir = File.join(File.dirname(__FILE__), 'tmp')
      FileUtils.mkdir_p(@tmp_dir)
      generator.quiet = true
      generator.render(
        File.expand_path('manifest_tmpl.yml.erb', File.dirname(__FILE__)),
        "#{@tmp_dir}/manifest.yml")
      expect(File.open("#{@tmp_dir}/manifest.yml").read).to eq("---\ntest: \"***\"\n")
    end

    it 'stores key file' do
      @tmp_dir = File.join(File.dirname(__FILE__), 'tmp')
      FileUtils.mkdir_p(@tmp_dir)
      generator.metadata_file = File.expand_path('metadata.yml',
                                                 File.dirname(__FILE__))
      logical = instance_double(Vault::Logical)
      secret = instance_double(Vault::Secret)
      expect(vault).to receive(:logical).and_return(logical)
      expect(logical).to receive(:read)
        .with('secret/aws/123456/bosh/keys/ssh_key').and_return(secret)
      expect(secret).to receive(:data)
        .and_return(value: 'test')
      generator.save_key('keys.ssh_key', "#{@tmp_dir}/microbosh.pem")
      expect(File.exist?("#{@tmp_dir}/microbosh.pem")).to be_truthy
      FileUtils.rm_rf(@tmp_dir)
    end
  end
  describe 'upload passwords' do
    let(:vault) do
      instance_double(Vault::Client)
    end
    let(:generator) do
      BoshManifestGenerator::ManifestGenerator.new(nil,
                                                   vault: vault)
    end

    it 'uploads password to vault' do
      logical = instance_double(Vault::Logical)
      expect(vault).to receive(:logical).and_return(logical)
      expect(logical).to receive(:write)
        .with('secret/aws/123456/bosh/foo/bar', value: '123456')
      generator.vault_prefix = 'secret/aws/123456/bosh'
      generator.upload_data('foo.bar', '123456')
    end
  end
end
