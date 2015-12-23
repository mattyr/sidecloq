require 'simplecov'
require 'codeclimate-test-reporter'
SimpleCov.start
CodeClimate::TestReporter.start

$TESTING = true
# disable minitest/parallel threads
ENV['N'] = '0'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sidecloq'

require 'minitest/autorun'

# from sidekiq's test helper:

REDIS_URL = ENV['REDIS_URL'] || 'redis://localhost/15'

Sidekiq.configure_client do |config|
  config.redis = { url: REDIS_URL, namespace: 'testy' }
end

module Sidecloq
  class Test < MiniTest::Test
  end
end

# also courtesy of sidekiq:
trap 'USR1' do
  threads = Thread.list

  puts
  puts '=' * 80
  puts "Received USR1 signal; printing all #{threads.count} thread backtraces."

  threads.each do |thr|
    description = thr == Thread.main ? 'Main thread' : thr.inspect
    puts
    puts "#{description} backtrace: "
    puts thr.backtrace.join("\n")
  end

  puts '=' * 80
end
