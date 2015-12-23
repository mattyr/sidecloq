require 'helper'

class TestRunner < Sidecloq::Test
  class DummyLocker
    def with_lock
      yield
    end
  end

  class DummyScheduler
    def run
    end
  end

  describe 'runner' do
    it 'uses locker in options' do
      r = Sidecloq::Runner.new(locker: DummyLocker.new)
      assert_instance_of DummyLocker, r.locker
    end

    it 'uses scheduler in options' do
      r = Sidecloq::Runner.new(scheduler: DummyScheduler.new)
      assert_instance_of DummyScheduler, r.scheduler
    end
  end
end
