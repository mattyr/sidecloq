require 'helper'

class TestSchedule < Sidecloq::Test
  describe 'schedule' do
    let(:schedule_hash) { { 'test_job' => {
      'class' => 'JobClass',
      'cron' => '0 7 * * *',
      'queue' => 'default'
    } } }
    let(:schedule) { Sidecloq::Schedule.from_hash(schedule_hash) }
    before { Sidekiq.redis{|r| r.flushdb} }

    it 'can save and load from a yml file' do
      require 'tempfile'

      file = Tempfile.new('schedule_test')

      schedule.save_yaml(file.path)

      loaded = Sidecloq::Schedule.from_yaml(file.path)

      assert_equal(loaded.job_specs.keys.first, 'test_job')
      assert_equal(loaded.job_specs.values.first['cron'], '0 7 * * *')

      file.delete
    end

    it 'can save and load from redis' do
      schedule.save_redis

      loaded = Sidecloq::Schedule.from_redis

      assert_equal(loaded.job_specs.keys.first, 'test_job')
      assert_equal(loaded.job_specs.values.first['cron'], '0 7 * * *')
    end
  end
end
