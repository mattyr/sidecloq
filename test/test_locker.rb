require_relative 'helper'

class TestLocker < Sidecloq::Test
  describe 'locker' do
    before { Sidekiq.redis(&:flushdb) }

    it 'obtains the lock when only locker' do
      solo = Sidecloq::Locker.new(lock_key: 'lockertest1')
      obtained_lock = false
      solo.with_lock do
        obtained_lock = true
        assert solo.locked?
      end
      solo.stop(0)
      assert obtained_lock
    end

    it 'does not obtain the lock when it is held' do
      holder = Sidecloq::Locker.new(lock_key: 'lockertest2')
      assert holder.try_to_get_or_refresh_lock

      non_holder = Sidecloq::Locker.new(lock_key: 'lockertest2')
      refute non_holder.try_to_get_or_refresh_lock
    end

    it 'obtains the lock when the leader loses it' do
      # TODO: i would love to not depend on timeouts/etc here while still
      # having tests that check with_lock directly

      ttl = 1 # seems like 1 is the min for redlock
      holder = Sidecloq::Locker.new(
        lock_key: 'lockertest3',
        ttl: ttl,
        check_interval: 1
      )

      release_holder_lock = Concurrent::Event.new
      Thread.new do
        holder.with_lock do
          release_holder_lock.wait
        end
      end

      obtainer = Sidecloq::Locker.new(
        lock_key: 'lockertest3',
        ttl: ttl,
        check_interval: 1
      )

      obtainer_got_lock = Concurrent::Event.new
      obtained_lock = false
      Thread.new do
        obtainer.with_lock do
          obtained_lock = true
          obtainer_got_lock.set
        end
      end

      refute obtained_lock
      release_holder_lock.set
      obtainer_got_lock.wait
      assert obtained_lock
      holder.stop(0)
      obtainer.stop(0)
    end

    it 'with_lock returns without yielding when lock not held and stop called' do
      holder = Sidecloq::Locker.new(lock_key: 'lockertest5')
      assert holder.try_to_get_or_refresh_lock

      non_holder = Sidecloq::Locker.new(lock_key: 'lockertest5')
      refute non_holder.try_to_get_or_refresh_lock

      thread_start_lock = Concurrent::Event.new
      did_return = false
      did_yield = false

      thread = Thread.new do
        thread_start_lock.set
        non_holder.with_lock do
          did_yield = true # should not happen
        end
        did_return = true
      end

      thread_start_lock.wait

      non_holder.stop

      thread.join(3) # should be fast if not failure

      refute did_yield
      assert did_return
    end
  end
end
