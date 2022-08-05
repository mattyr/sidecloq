source 'https://rubygems.org'

gemspec

platforms :mri, :rbx do
  gem 'pry'
  gem 'minitest-utils'
end

# https://github.com/sinatra/sinatra/blob/master/Gemfile
sidekiq_dep =
  case ENV['sidekiq']
  when /(\d+\.)+\d+/ then "~> " + ENV['sidekiq'].sub("sidekiq-", '')
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
