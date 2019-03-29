require 'helper'

class TestSchedule < Sidecloq::Test
  describe 'schedule' do
    let(:schedule_hash) do
      {
        'test_job' => {
          'class' => 'JobClass',
          'cron' => '0 7 * * *',
          'queue' => 'default',
          'args' => { 'batch' => 100 }
        }
      }
    end
    let(:nested_schedule_hash) do
      {
        'test' => {
          'test_job' => {
            'class' => 'JobClass',
            'cron' => '0 7 * * *',
            'queue' => 'default',
            'args' => { 'batch' => 100 }
          }
        }
      }
    end
    let(:schedule) { Sidecloq::Schedule.from_hash(schedule_hash) }
    before { Sidekiq.redis(&:flushdb) }

    it 'can save and load from a yml file' do
      require 'tempfile'

      file = Tempfile.new('schedule_test')

      schedule.save_yaml(file.path)

      loaded = Sidecloq::Schedule.from_yaml(file.path)

      assert_equal('test_job', loaded.job_specs.keys.first)
      assert_equal('0 7 * * *', loaded.job_specs.values.first['cron'])
      assert_equal({'batch' => 100}, loaded.job_specs.values.first['args'])

      file.delete
    end

    it 'can load by env from a nested yml file' do
      require 'tempfile'

      file = Tempfile.new('nested_schedule_test')

      rails = class_double('Rails')
      expect(rails).to receive(:env).and_return 'test'

      loaded = Sidecloq::Schedule.from_yaml(file.path)

      assert_equal('test_job', loaded.job_specs.keys.first)
      assert_equal('0 7 * * *', loaded.job_specs.values.first['cron'])
      assert_equal({'batch' => 100}, loaded.job_specs.values.first['args'])

      file.delete
    end

    it 'can save and load from redis' do
      schedule.save_redis

      loaded = Sidecloq::Schedule.from_redis

      assert_equal('test_job', loaded.job_specs.keys.first)
      assert_equal('0 7 * * *', loaded.job_specs.values.first['cron'])
    end

    it 'clears existing schedule when saved' do
      schedule.save_redis
      schedule_2 = Sidecloq::Schedule.from_hash(schedule_hash.tap do |x|
        x['test_job']['class'] = 'JobClass2'
      end)
      schedule_2.save_redis
      assert_equal 'JobClass2', Sidecloq::Schedule.from_redis.job_specs['test_job']['class']
    end
  end
end
