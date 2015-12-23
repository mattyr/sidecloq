module Sidecloq
  # Locker obtains or waits for an exclusive lock on a key in redis
  class Locker
    include Utils

    DEFAULT_LOCK_KEY = 'sidecloq_leader_lock'

    def initialize(options = {})
      # we keep a connection from the pool by default
      @redis = options[:redis] || Sidekiq.redis_pool.checkout
      @key = options[:lock_key] || DEFAULT_LOCK_KEY
      @ttl = options[:ttl] || 60
      @check_interval = options[:check_interval] || 15
      @lock_manager = Redlock::Client.new([@redis])
      @obtained_lock = Concurrent::Event.new
    end

    # blocks until lock is obtained, then yields
    def with_lock
      start
      @obtained_lock.wait
      yield
      stop
    end

    def stop(timeout = nil)
      return unless @check_task

      logger.debug('Stopping locker check task')
      @check_task.shutdown
      @check_task.wait_for_termination(timeout)
      logger.debug('Stopped locker check task')
    end

    def locked?
      @obtained_lock.set?
    end

    private unless $TESTING

    def start
      logger.debug('Starting locker check task')
      @check_task = Concurrent::TimerTask.new(
        execution_interval: @check_interval,
        run_now: true
      ) do
        try_to_get_or_refresh_lock
      end
      @check_task.execute
    end

    def try_to_get_or_refresh_lock
      # redlock is in ms, not seconds
      @lock = @lock_manager.lock(@key, @ttl * 1000, extend: @lock)
      @obtained_lock.set if @lock
      logger.debug("Leader lock #{'not ' unless @lock}held")
      @lock
    end
  end
end
