# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = 'bosh_manifest_generator'
  spec.version       = '0.0.1'
  spec.summary       = 'a gem for things'
  spec.authors       = ['Johannes Engelke']
  spec.email         = 'johannes.engelke@hybris.com'
  spec.homepage      = 'https://github.com/hybris/bosh-manifest-generator'
  spec.description   = 'Much longer explanation of the example!'
  spec.license       = ''

  spec.files         = Dir.glob('{lib,bin}/**/*')
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.add_development_dependency 'rspec', '~>3.4.0'
  spec.add_development_dependency 'simplecov', '~>0.11.0'
  spec.add_runtime_dependency 'vault', '~> 0.1'
end
