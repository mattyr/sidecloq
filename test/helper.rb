require 'simplecov'
if ENV['CI']
  require 'simplecov_json_formatter'
  SimpleCov.formatter = SimpleCov::Formatter::JSONFormatter
end
SimpleCov.start

$TESTING = true
# disable minitest/parallel threads
ENV["MT_CPU"] = "0"
ENV['N'] = '0'
ENV["BACKTRACE"] = "1"

require "bundler/setup"
Bundler.require(:default, :test)

require 'minitest/autorun'

# from sidekiq's test helper:

REDIS_URL = ENV['REDIS_URL'] || 'redis://localhost/15'

Sidekiq.configure_client do |config|
  config.redis = { url: REDIS_URL } 
end

Sidekiq.logger.level = ENV['LOG_LEVEL'] || Logger::ERROR

module Sidecloq
  class Test < Minitest::Test
  end
end

class DummyLocker
  def with_lock
    yield
  end

  def locked?
    true
  end

  def stop(timeout = nil)
  end
end

class DummyScheduler
  def run
  end

  def stop(timeout = nil)
  end
end

class DummyJob
  include Sidekiq::Worker
end

require 'active_job'

ActiveJob::Base.queue_adapter = :sidekiq
ActiveJob::Base.logger.level = Logger::ERROR

class DummyActiveJob < ActiveJob::Base
end

def define_rails!
  return if defined? Rails::Engine

  if !defined?(Rails)
    Object.const_set('Rails', Module.new)
  end

  Rails.const_set('Engine', Class.new)

  return if Rails.respond_to?(:root)

  Rails.class_eval do

    @env = 'development'

    def self.root
      File.expand_path('../', __FILE__)
    end

    def self.env
      @env
    end

    def self.env=(env = nil)
      @env = env
    end
  end
end

def undefine_rails!
  if defined? Rails::Engine
    Rails.send(:remove_const, :Engine) if defined? Rails::Engine
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
