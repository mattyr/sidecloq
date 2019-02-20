module Sidecloq
  # Runner encapsulates a locker and a scheduler, running scheduler when
  # "elected" leader
  class Runner
    include Utils

    attr_reader :locker, :scheduler

    def initialize(options = {})
      @locker = extract_locker(options)
      @scheduler = extract_scheduler(options)
    end

    def run
      @thread = Thread.new do
        logger.info('Runner starting')
        @locker.with_lock do
          # i am the leader
          logger.info('Obtained leader lock')
          @scheduler.run
        end
        logger.info('Runner ending')
      end
    end

    def stop(timeout = nil)
      logger.debug('Stopping runner')
      if @locker.locked?
        @scheduler.stop(timeout)
        @locker.stop(timeout)
        @thread.join if @thread
      end
      logger.debug('Stopped runner')
    end

    private unless $TESTING

    def extract_locker(options)
      return options[:locker] if options[:locker]
      Locker.new(options[:locker_options] || {})
    end

    def extract_scheduler(options)
      return options[:scheduler] if options[:scheduler]
      Scheduler.new(options[:schedule], options[:scheduler_options] || {})
    end
  end
end
