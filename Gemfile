source 'https://rubygems.org'

gemspec

platforms :mri, :rbx do
  gem 'pry'
  gem 'minitest-utils'
end

sidekiq_dep =
  case ENV['sidekiq'].to_s.sub('sidekiq-', '')
  when /(?:\d+\.)+\d+/ then "~> #{$&}#{'.0' if Gem::Version.new($&).segments.size == 2}"
  else {github: 'mperham/sidekiq', branch: ENV['sidekiq']}
  end

gem 'sidekiq', sidekiq_dep

if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.2.2")
  # rack >= 2.0 requires ruby >= 2.2.2
  gem 'rack', '< 2.0'
  # activejob >= 5 requires ruby >= 2.2.2
  gem 'activejob', '< 5'
end

group :test do
  gem "simplecov"
end
