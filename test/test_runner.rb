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
  end
end
