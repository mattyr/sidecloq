module Sidecloq
  # Scheduler enqueues jobs according to the given schedule
  class Scheduler
    include Utils

    def initialize(schedule, options = {})
      @schedule = schedule
      @options = options
      @loaded = Concurrent::Event.new
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
      rufus.shutdown(:kill)
      rufus.thread.join(timeout)
      logger.info('Stopped scheduler')
    end

    private unless $TESTING

    def wait_for_loaded
      @loaded.wait
    end

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
      @loaded.set
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
      logger.info "enqueuing #{name}"

      # failed enqueuing should not b0rk stuff
      begin
        JobEnqueuer.new(spec).enqueue
      rescue => e
        logger.info "error enqueuing #{name} - #{e.class.name}: #{e.message}"
      end
    end
  end
end
