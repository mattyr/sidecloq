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
    let(:rails_env_schedule_hash) do
      {
        'test' => {
          'rails_env_test_job' => {
            'class' => 'JobClass'
          }
        }
      }
    end
    let(:rack_env_schedule_hash) do
      {
        'staging' => {
          'rack_env_test_job' => {
            'class' => 'JobClass'
          }
        }
      }
    end
    let(:schedule) { Sidecloq::Schedule.from_hash(schedule_hash) }
    let(:rails_env_schedule) { Sidecloq::Schedule.from_hash(rails_env_schedule_hash) }
    let(:rack_env_schedule) { Sidecloq::Schedule.from_hash(rack_env_schedule_hash) }
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

    it 'can load Rails.env based nested yml file' do
      require 'tempfile'

      define_rails!
      ::Rails.env = 'test'

      file = Tempfile.new('rail_senv_schedule_test')

      rails_env_schedule.save_yaml(file.path)

      loaded = Sidecloq::Schedule.from_yaml(file.path)

      assert_equal('rails_env_test_job', loaded.job_specs.keys.first)

      file.delete
    end

    it 'can load RACK_ENV based nested yml file' do
      require 'tempfile'

      define_rails!
      ::Rails.env = nil
      ENV['RACK_ENV'] = 'staging'

      file = Tempfile.new('rack_env_schedule_test')

      rack_env_schedule.save_yaml(file.path)

      loaded = Sidecloq::Schedule.from_yaml(file.path)

      assert_equal('rack_env_test_job', loaded.job_specs.keys.first)

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
