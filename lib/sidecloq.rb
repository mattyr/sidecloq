require 'sidekiq'
require 'concurrent'
require 'redlock'
require 'multi_json'
require 'rufus-scheduler'

require 'sidecloq/utils'
require 'sidecloq/schedule'
require 'sidecloq/locker'
require 'sidecloq/scheduler'
require 'sidecloq/runner'
require 'sidecloq/version'

# Sideloq provides a lightweight recurring job scheduler for sidekiq
module Sidecloq
  def self.install
    Sidekiq.configure_server do |config|
      config.on(:startup) do
        Sidecloq.startup
      end

      config.on(:shutdown) do
        Sidecloq.shutdown
      end
    end
  end

  def self.options
    @options ||= {}
  end

  def self.options=(opts)
    @options = opts
  end

  def self.configure
    yield options
  end

  def self.startup
    options[:schedule] ||= extract_schedule unless options[:scheduler]

    @runner = Runner.new(options)
    @runner.run
  end

  def self.shutdown
    @runner.stop(options[:timeout] || 10) if @runner
  end

  def self.extract_schedule
    # do our best to do this automatically

    # schedule handed to us
    return options[:schedule] if options[:schedule]

    # try for a file
    options[:schedule_file] ||= 'config/sidecloq.yml'
    if File.exist?(options[:schedule_file])
      return Schedule.from_yaml(options[:schedule_file])
    elsif defined?(Rails)
      # try rails-root-relative
      full_path = File.join(Rails.root, options[:schedule_file])
      if File.exist?(full_path)
        options[:schedule_file] = full_path
        return Schedule.from_yaml(options[:schedule_file])
      end
    end

    # return an empty schedule
    Schedule.new({})
  end
end

Sidecloq.install
