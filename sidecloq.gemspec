# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sidecloq/version'

Gem::Specification.new do |spec|
  spec.name          = 'sidecloq'
  spec.version       = Sidecloq::VERSION
  spec.authors       = ['Matt Robinson']
  spec.email         = ['robinson.matty@gmail.com']

  spec.summary       = 'Recurring / Periodic / Scheduled / Cron job extension for Sidekiq'
  spec.description   = spec.summary
  spec.homepage      = 'http://github.com/mattyr/sidecloq'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|assets)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'sidekiq', '>= 6.0.0', '< 8'
  spec.add_dependency 'redlock', '>= 2.0.0', '< 3'
  # redlock needs redis-client
  spec.add_dependency 'redis-client', '>= 0.14.0'
  # mimics some dev dependencies of sidekiq:
  spec.add_dependency 'concurrent-ruby'
  spec.add_dependency 'rufus-scheduler', '~> 3.9'

  spec.add_development_dependency 'rake', '>= 10.0'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency "appraisal"
  spec.add_development_dependency 'activejob'
  spec.add_development_dependency 'rack', '< 3'
  spec.add_development_dependency 'webrick'
end
