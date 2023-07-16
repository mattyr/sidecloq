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

group :test do
  gem "simplecov"
end
