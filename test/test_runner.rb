require 'helper'

class TestRunner < Sidecloq::Test
  describe 'runner' do
    it 'uses locker in options' do
      r = Sidecloq::Runner.new(locker: DummyLocker.new)
      assert_instance_of DummyLocker, r.locker
    end

    it 'uses scheduler in options' do
      r = Sidecloq::Runner.new(scheduler: DummyScheduler.new)
      assert_instance_of DummyScheduler, r.scheduler
    end

    it 'runs in its own thread (non-blocking)' do
      r = Sidecloq::Runner.new(
        locker: DummyLocker.new,
        scheduler: DummyScheduler.new
      )

      r.run

      assert true

      r.stop
    end

    it 'stops when not leader (non-blocking)' do
      leader = Sidecloq::Runner.new(
        locker: DummyLocker.new(true),
        scheduler: DummyScheduler.new
      )
      leader.run
      assert true

      runner = Sidecloq::Runner.new(
        locker: DummyLocker.new(false),
        scheduler: DummyScheduler.new
      )
      runner.run
      assert true

      runner.stop
      assert true

      leader.stop
      assert true
    end
  end
end
