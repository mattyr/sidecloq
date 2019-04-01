module Sidecloq
  # Schedule loads and parses recurring job specs from files, hashes, and redis
  class Schedule
    include Utils

    REDIS_KEY = :sidecloq_schedule

    attr_reader :job_specs

    def initialize(specs)
      @job_specs = specs
    end

    def self.from_yaml(filename)
      from_hash(YAML.load_file(filename))
    end

    def self.from_redis
      specs = {}

      if redis { |r| r.exists(REDIS_KEY) }
        specs = {}

        redis { |r| r.hgetall(REDIS_KEY) }.tap do |h|
          h.each do |name, config|
            specs[name] = JSON.parse(config)
          end
        end
      end

      from_hash(specs)
    end

    def self.from_hash(hash)
      hash = hash[env] if hash.key?(env)

      specs = hash.each_with_object({}) do |(name, spec), memo|
        memo[name] = spec.dup.tap do |s|
          s['class'] = name unless spec.key?('class') || spec.key?(:class)
          s['args'] = s['args'] || s[:args] || []
        end
      end

      new(specs)
    end

    def save_yaml(filename)
      File.open(filename, 'w') do |h|
        h.write @job_specs.to_yaml
      end
    end

    def save_redis
      reset_redis_schedule
      save_all_to_redis
    end

    private unless $TESTING

    def reset_redis_schedule
      redis do |r|
        r.hkeys(REDIS_KEY).each do |k|
          r.hdel(REDIS_KEY, k)
        end
      end
    end

    def save_all_to_redis
      redis do |r|
        @job_specs.each do |name, spec|
          r.hset(REDIS_KEY, name, spec.to_json)
        end
      end
    end

    def self.env
      rails_env || rack_env
    end

    def self.rails_env
      Rails.env if defined?(Rails)
    end

    def self.rack_env
      ENV['RACK_ENV']
    end
  end
end
