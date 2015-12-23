module Sidecloq
  module Web
    VIEW_PATH = File.expand_path('../../../web/views', __FILE__)

    def self.registered(app)

      app.get '/recurring' do
        @schedule = Schedule.from_redis

        erb File.read(File.join(VIEW_PATH, 'recurring.erb'))
      end

      app.post '/recurring/:name/enqueue' do |name|
        if spec = Sidecloq::Schedule.from_redis.job_specs[name]
          Sidekiq::Client.push(spec)
        end
        redirect "#{root_path}recurring"
      end

    end
  end
end

Sidekiq::Web.register(Sidecloq::Web)
Sidekiq::Web.tabs['Recurring'] = 'recurring'
