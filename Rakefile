require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/test_*.rb']
end

task default: :test

desc 'Run the Sidekiq web interface (w/Sidecloq)'
task :web do
  require 'sidekiq'
  require 'sidecloq'

  Sidekiq.configure_client do |config|
    config.redis = {
      url: 'redis://localhost:6379/0',
      size: 1,
      namespace: 'sidecloq'
    }
  end

  # throw a fake job in
  Sidecloq.configure do |config|
    sched = Sidecloq::Schedule.from_hash({
      my_scheduled_job: {
        class: 'DoWork',
        cron: '* * * * *',
        queue: 'default'
      }
    })
    sched.save_redis
    config[:schedule] = sched
  end

  class DoWork
    include Sidekiq::Worker
  end

  require 'sidekiq/web'
  require 'sidecloq/web'

  Rack::Server.start(
    app: Sidekiq::Web
  )
end
