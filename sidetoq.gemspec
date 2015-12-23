# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sidecloq/version'

Gem::Specification.new do |spec|
  spec.name          = 'sidecloq'
  spec.version       = Sidecloq::VERSION
  spec.authors       = ['Matt Robinson']
  spec.email         = ['robinson.matty@gmail.com']

  spec.summary       = 'Recurring jobs for Sidekiq'
  spec.description   = spec.summary
  spec.homepage      = 'http://github.com/mattyr/sidecloq'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'sidekiq', '~> 4.0.1'
  spec.add_dependency 'redlock', '~> 0.1.2'
  # mimics some dev dependencies of sidekiq:
  spec.add_dependency 'concurrent-ruby'
  spec.add_dependency 'sinatra', '~> 1.4', '>= 1.4.6'
  spec.add_dependency 'redis-namespace', '~> 1.5', '>= 1.5.2'
  spec.add_dependency 'multi_json', '~> 1.11'
  spec.add_dependency 'rufus-scheduler', '~> 3.1', '>= 3.1.10'

  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest'
end
