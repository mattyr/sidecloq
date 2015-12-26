module Sidecloq
  # Scheduler enqeues jobs according to the given schedule
  class Scheduler
    include Utils

    def initialize(schedule, options = {})
      @schedule = schedule
      @options = options
    end

    # run queues jobs per their schedules, blocking forever
    def run
      logger.info('Loading schedules into redis')
      sync_with_redis
      logger.info('Starting scheduler')
      load_schedule_into_rufus
      rufus.join
    end

    def stop(timeout = nil)
      logger.info("Stopping scheduler (timeout: #{timeout})")
      if timeout
        t = Concurrent::ScheduledTask.new(timeout) do
          rufus.shutdown(:kill) if rufus.up?
        end
        Thread.new do
          rufus.shutdown(:wait)
          t.cancel
        end
      else
        rufus.shutdown(:wait)
      end
      rufus.join
      logger.info('Stopped scheduler')
    end

    private unless $TESTING

    def rufus
      @rufus ||= Rufus::Scheduler.new
    end

    def sync_with_redis
      @schedule.save_redis
    end

    def load_schedule_into_rufus
      logger.debug('Scheduling jobs')
      @schedule.job_specs.each do |name, spec|
        load_into_rufus(name, spec)
      end
    end

    def load_into_rufus(name, spec)
      # rufus will loop indefinitely trying to find the next event time if the
      # cronline is impossible, like '0 5 31 2 *'
      if will_never_run(spec['cron'])
        logger.info("Impossible cronline detected, not scheduling #{name}: #{spec}")
      else
        logger.info("Scheduling #{name}: #{spec}")
        rufus.cron(spec['cron']) do
          safe_enqueue_job(name, spec)
        end
      end
    end

    def safe_enqueue_job(name, spec)
      logger.info "enqueueing #{name}"

      # failed enqeueuing should not b0rk stuff
      begin
        enqueue_job!(spec)
      rescue => e
        logger.info "error enqueuing #{name} - #{e.class.name}: #{e.message}"
      end
    end

    # can raise exceptions, but shouldn't
    def enqueue_job!(spec)
      Sidekiq::Client.push(spec)
    end
  end
end
