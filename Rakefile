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
      size: 1
    }
  end

  # throw some fake jobs in
  Sidecloq.configure do |config|
    sched = Sidecloq::Schedule.from_hash({
      my_scheduled_job: {
        class: 'DoWork',
        cron: '* * * * *',
        queue: 'default'
      },
      my_scheduled_job2: {
        class: 'DoWorkWithQueue',
        cron: '* * * * *'
      }
    })
    sched.save_redis
    config[:schedule] = sched
  end

  class DoWork
    include Sidekiq::Worker
  end

  class DoWorkWithQueue
    include Sidekiq::Worker
    sidekiq_options queue: "not_default"
  end

  require 'rack/server'
  require 'rack/session/cookie'
  require 'sidekiq/web'
  require 'sidecloq/web'

  Rack::Server.start(
    app: Rack::Session::Cookie.new(
      Sidekiq::Web,
      secret: SecureRandom.hex(32),
      same_site: true,
      max_age: 86400
    )
  )
end
