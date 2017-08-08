module Sidecloq
  class JobEnqueuer
    attr_reader :spec, :klass

    def initialize(spec)
      # Dup to prevent JID reuse in subsequent enqueue's
      @spec = spec.dup
      @klass = spec['class'].constantize
    end

    def enqueue
      if active_job_class?
        initialize_active_job_class.enqueue(queue: spec['queue'])
      else
        Sidekiq::Client.push(spec)
      end
    end

    private unless $TESTING

    def active_job_class?
      defined?(ActiveJob::Base) && klass < ActiveJob::Base
    end

    def initialize_active_job_class
      args = spec['args']

      if args.is_a?(Array)
        klass.new(*args)
      else
        klass.new(args)
      end
    end
  end
end
