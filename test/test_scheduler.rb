require_relative 'helper'
require 'sidekiq/api'

class TestScheduler < Sidecloq::Test
  describe 'scheduler' do
    let(:specs) do
      {test: {'cron' => '* * * * *', 'class' => 'Foo', 'args' => []}}
    end
    let(:schedule) { Sidecloq::Schedule.new(specs) }
    let(:scheduler) { Sidecloq::Scheduler.new(schedule) }

    it 'blocks when calling run' do
      @stopped = false
      Thread.new do
        scheduler.run
        raise "Should not have gotten here" unless @stopped
      end
      @stopped = true
      scheduler.stop(1)
    end

    it 'pushes jobs through sidekiq client' do
      Sidekiq::Stats.new.reset
      scheduler.safe_enqueue_job('test', specs[:test])
      assert_equal 1, Sidekiq::Stats.new.enqueued
    end

    it 'does not raise errors when job spec is bad' do
      Sidekiq::Stats.new.reset
      scheduler.safe_enqueue_job('bad', {})
      assert_equal 0, Sidekiq::Stats.new.enqueued
    end
  end
end
