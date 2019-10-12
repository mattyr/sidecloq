module Sidecloq
  # Useful stuff
  module Utils
    # Sets the Sidekiq::Logging context automatically with direct calls to
    # *.logger
    class ContextLogger
      def initialize(ctx)
        @context = ctx
      end

      def sidekiq_logging_context_method
        @sidekiq_logging_context_method ||=
          begin
            if defined? Sidekiq::Logging
              # sidekiq < 6
              Sidekiq::Logging.method(:with_context)
            elsif defined?(Sidekiq::Context)
              # sidekiq 6, <= 6.0.1
              Sidekiq::Context.method(:with)
            else
              # sidekiq 6, master
              Sidekiq.logger.method(:with_context)
            end
          end
      end

      def method_missing(meth, *args)
        sidekiq_logging_context_method.call(@context) do
          Sidekiq.logger.send(meth, *args)
        end
      end
    end


    def logger
      @logger ||= ContextLogger.new(
        defined?(Sidekiq::Logging) ? 'Sidecloq' : {sidecloq: true}
      )
    end

    def redis(&block)
      self.class.redis(&block)
    end

    # finds cron lines that are impossible, like '0 5 31 2 *'
    # note: does not attempt to fully validate the cronline
    def will_never_run(cronline)
      # look for non-existent day of month
      split = cronline.split(/\s+/)
      if split.length > 3 && split[2] =~ /\d+/ && split[3] =~ /\d+/

        month = split[3].to_i
        day = split[2].to_i
        # special case for leap-year detection
        return true if month == 2 && day <= 29

        return !Date.valid_date?(0, month, day)

      else
        false
      end
    end

    module ClassMethods
      def redis(&block)
        if block
          Sidekiq.redis(&block)
        else
          Sidekiq.redis_pool.checkout
        end
      end
    end

    def self.included(klass)
      klass.extend(ClassMethods)
    end
  end
end
