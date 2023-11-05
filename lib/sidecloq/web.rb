module Sidecloq
  # Plugin for sidekiq-web
  module Web
    VIEW_PATH = File.expand_path('../../../web/views', __FILE__)
    LOCALES = File.expand_path('../../../web/locales', __FILE__)

    def self.registered(app)
      app.get '/recurring' do
        @schedule = Schedule.from_redis

        erb File.read(File.join(VIEW_PATH, 'recurring.erb'))
      end

      app.post '/recurring/:name/enqueue' do |name|
        job_name = respond_to?(:route_params) ? route_params[:name] : name

        # rubocop:disable Lint/AssignmentInCondition
        if spec = Sidecloq::Schedule.from_redis.job_specs[job_name]
          JobEnqueuer.new(spec).enqueue
        end
        # rubocop:enableLint/AssignmentInCondition
        redirect "#{root_path}recurring"
      end
    end
  end
end

Sidekiq::Web.locales << Sidecloq::Web::LOCALES

Sidekiq::Web.register(Sidecloq::Web)
Sidekiq::Web.tabs['Recurring'] = 'recurring'
