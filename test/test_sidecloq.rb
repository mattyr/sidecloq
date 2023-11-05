require_relative 'helper'

class TestSidecloq < Sidecloq::Test
  describe 'sidecloq' do
    it 'has a version number' do
      refute_nil ::Sidecloq::VERSION
    end

    it 'is configurable by assignment' do
      Sidecloq.options[:test] = 'something'
      assert_equal 'something', Sidecloq.options[:test]

      Sidecloq.options = {test: 'something2'}
      assert_equal 'something2', Sidecloq.options[:test]
    end

    it 'is configurable by block syntax' do
      Sidecloq.configure do |options|
        options[:test_block] = 'something else'
      end

      assert_equal 'something else', Sidecloq.options[:test_block]
    end

    describe 'lifecycle' do
      before do
        Sidecloq.configure do |opts|
          opts[:scheduler] = DummyScheduler.new
          opts[:locker] = DummyLocker.new
        end
      end

      it 'installs into sidekiq automatically' do
        require 'sidekiq/cli'
        Sidecloq.install
        opts = Sidekiq.respond_to?(:options) ? Sidekiq.options : Sidekiq.default_configuration
        assert_equal 1, opts[:lifecycle_events][:startup].length
        assert_equal 1, opts[:lifecycle_events][:shutdown].length
      end

      it 'can start up and shutdown' do
        Sidecloq.startup
        assert Sidecloq.running?
        Sidecloq.shutdown
        refute Sidecloq.running?
      end
    end

    describe 'schedule file' do
      before { Sidecloq.options = {}}

      it 'uses schedule from options if given' do
        s = Sidecloq::Schedule.new({})
        Sidecloq.options[:schedule] = s
        assert_equal s, Sidecloq.extract_schedule
      end

      it 'loads a given filename' do
        Sidecloq.options[:schedule_file] = File.expand_path('../fixtures/sidecloq.yml', __FILE__)
        assert_equal 3, Sidecloq.extract_schedule.job_specs.keys.length
      end

      it 'finds a config file relative to rails root' do
        define_rails!
        Sidecloq.options[:schedule_file] = '/fixtures/sidecloq.yml'
        assert_equal 3, Sidecloq.extract_schedule.job_specs.keys.length
      end

      it 'defaults to an empty schedule' do
        assert_equal 0, Sidecloq.extract_schedule.job_specs.keys.length
      end
    end
  end
end
