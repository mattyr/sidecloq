require_relative 'helper'
require 'sidekiq/api'

class TestScheduler < Sidecloq::Test
  describe 'scheduler' do
    let(:specs) do
      {test: {'cron' => '* * * * *', 'class' => 'Foo', 'args' => []}}
    end
    let(:schedule) { Sidecloq::Schedule.new(specs) }
    let(:scheduler) { Sidecloq::Scheduler.new(schedule) }
    before { Sidekiq.redis(&:flushdb) }

    it 'blocks when calling run' do
      t = Thread.new do
        scheduler.run
      end
      while !scheduler.loaded?
        sleep(0.01)
      end
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
