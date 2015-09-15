require 'vault'
require 'yaml'
require 'erb'

module BoshManifestGenerator
  # ManifestGenerator is used to manage bosh manifest tmeplates.
  class ManifestGenerator
    attr_accessor :metadata_file, :vault, :vault_token_file, :vault_prefix

    def initialize(working_dir = nil, options = {})
      @working_dir = working_dir
      @metadata_file = options[:metadata_file] || "#{@working_dir}/metadata.yml"
      @verify_ssl = options[:verify_ssl] || ENV['VERIFY_SSL']
      read_vault_options(options)
    end

    def metadata
      YAML.load_file(@metadata_file)
    end

    def account_id
      metadata['meta']['aws']['account_id']
    end

    def vault_prefix
      @vault_prefix || "secret/aws/#{account_id}/bosh"
    end

    def vault
      @vault || create_vault
    end

    def p(key)
      vault_key = "#{vault_prefix}/#{key.gsub(/\./, '/')}"
      puts('Get key ' + vault_key)
      vault.logical.read(vault_key).data[:value]
    end

    def render(template, file)
      renderer = ERB.new(File.new(template).read)

      File.open(file, 'w') do |f|
        f.write renderer.result(binding)
      end
    end

    def save_key(key, file)
      File.open(file, 'w') do |f|
        f.write p(key)
      end
    end

    def upload_data(key, password)
      vault_key = "#{vault_prefix}/#{key.gsub(/\./, '/')}"
      vault.logical.write(vault_key, value: password)
    end

    private

    def read_vault_options(options)
      @vault_address = options[:vault_address] || ENV['VAULT_ADDR']
      @vault_user = options[:vault_user] || ENV['VAULT_USER_ID']
      @vault_app = options[:vault_app] || ENV['VAULT_APP_ID']
      @vault_token_file = options[:vault_token_file] ||
                          "#{ENV['HOME']}/.vault-token"
      @vault_prefix = options[:vault_prefix]
      @vault = options[:vault]
    end

    def create_vault
      @vault = Vault::Client.new(address: @vault_address, ssl_verify: false)
      if File.exist?(@vault_token_file)
        @vault.token = File.open("#{ENV['HOME']}/.vault-token").read
      else
        @vault.auth.app_id(@vault_app, @vault_user)
      end
      @vault
    end
  end
end
