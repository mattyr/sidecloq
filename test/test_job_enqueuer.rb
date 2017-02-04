require_relative 'helper'
require 'sidekiq/api'

class TestJobEnqueuer < Sidecloq::Test
  describe 'job_enqueuer' do
    before { Sidekiq.redis(&:flushdb) }
    let(:enqueuer) { Sidecloq::JobEnqueuer.new(spec) }

    describe 'normal job' do
      let(:spec) { {'cron' => '1 * * * *', 'class' => 'DummyJob', 'args' => []} }

      it 'determines that it is a kind of normal job' do
        refute enqueuer.active_job_class?
      end

      it 'is queued' do
        enqueuer.enqueue
        job = Sidekiq::Queue.new.first
        assert_equal 'DummyJob', job.klass
      end
    end

    describe 'active_job' do
      let(:spec) { {'cron' => '1 * * * *', 'class' => 'DummyActiveJob', 'args' => args} }
      let(:args) { [] }

      it 'determines that it is a kind of active_job' do
        assert enqueuer.active_job_class?
      end

      it 'is queued' do
        enqueuer.enqueue
        job = Sidekiq::Queue.new.first
        assert_equal 'ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper', job.klass
        assert_equal 'DummyActiveJob', job.args[0]['job_class']
      end

      describe 'with array args' do
        let(:args) { [123] }

        it "passes args correctly" do
          enqueuer.enqueue
          job = Sidekiq::Queue.new.first
          assert_equal 123, job.args[0]['arguments'][0]
        end
      end

      describe 'with hash args' do
        let(:args) { {'foo' => 'bar'} }

        it "passes args correctly" do
          enqueuer.enqueue
          job = Sidekiq::Queue.new.first
          assert_equal 'bar', job.args[0]['arguments'][0]['foo']
        end
      end

      describe 'with no args' do
        let(:args) { [] }

        it "passes args correctly" do
          enqueuer.enqueue
          job = Sidekiq::Queue.new.first
          assert_nil job.args[0]['arguments'][0]
        end
      end
    end
  end
end
