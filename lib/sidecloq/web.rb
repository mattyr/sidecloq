module Sidecloq
  # Plugin for sidekiq-web
  module Web
    VIEW_PATH = File.expand_path('../../../web/views', __FILE__)

    def self.registered(app)
      app.get '/recurring' do
        @schedule = Schedule.from_redis
        @helpers = Sidecloq::Web::Helpers
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

    ##
    # Helpers for the the web view
    class Helpers
      def self.next_run(cronline)
        Fugit.parse_cron(cronline).next_time.send(:to_time) rescue nil
      end
      def self.time_in_words(t)
        return unless t.is_a?(Time)
        t.strftime("%D %R")
      end
      def self.time_in_words_to_now(t)
        return unless t.is_a?(Time)
        hrs = (t - Time.now) / 1.hour
        min = hrs.modulo(1) * 60
        "#{hrs.truncate} hrs #{min.ceil} min"
      end
    end
  end

end

Sidekiq::Web.register(Sidecloq::Web)
Sidekiq::Web.tabs['Recurring'] = 'recurring'
