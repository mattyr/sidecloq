require_relative 'helper'
require 'sidekiq/api'

class TestScheduler < Sidecloq::Test
  describe 'scheduler' do
    let(:specs) do
      {test: {'cron' => '1 * * * *', 'class' => 'DummyJob', 'args' => []}}
    end
    let(:schedule) { Sidecloq::Schedule.new(specs) }
    let(:scheduler) { Sidecloq::Scheduler.new(schedule) }
    before { Sidekiq.redis(&:flushdb) }

    it 'blocks when calling run' do
      @unblocked = false
      t = Thread.new do
        scheduler.run
        raise 'Did not block' unless @unblocked
      end

      # for some reason rbx doesn't seem to allow the thread to run
      # appropriately without a small sleep here.  would be nice to remove
      # this, but for now is necessary for test to work
      if RUBY_ENGINE == 'rbx'
        sleep(1)
      end

      scheduler.wait_for_loaded
      @unblocked = true
      scheduler.stop(1)
      t.join
    end

    it 'pushes jobs through sidekiq client' do
      scheduler.safe_enqueue_job('test', specs[:test])
      assert_equal 1, Sidekiq::Stats.new.enqueued
    end

    it 'does not raise errors when job spec is bad' do
      scheduler.safe_enqueue_job('bad', {})
      assert_equal 0, Sidekiq::Stats.new.enqueued
    end
  end
end
