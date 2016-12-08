![Sidecloq](assets/clock_a_clock_on_the_side.png)

# Sidecloq

[![Build Status](https://travis-ci.org/mattyr/sidecloq.svg)](https://travis-ci.org/mattyr/sidecloq)
[![Gem Version](https://badge.fury.io/rb/sidecloq.svg)](https://badge.fury.io/rb/sidecloq)
[![Code Climate](https://codeclimate.com/github/mattyr/sidecloq/badges/gpa.svg)](https://codeclimate.com/github/mattyr/sidecloq)
[![Test Coverage](https://codeclimate.com/github/mattyr/sidecloq/badges/coverage.svg)](https://codeclimate.com/github/mattyr/sidecloq/coverage)
[![Dependency Status](https://gemnasium.com/mattyr/sidecloq.svg)](https://gemnasium.com/mattyr/sidecloq)

Recurring / Periodic / Scheduled / Cron job extension for
[Sidekiq](https://github.com/mperham/sidekiq)

## Why

There are several options for running periodic tasks with Sidekiq,
including [Sidetiq](https://github.com/tobiassvn/sidetiq),
[sidekiq-scheduler](https://github.com/Moove-it/sidekiq-scheduler),
[sidekiq-cron](https://github.com/ondrejbartas/sidekiq-cron), as well as
[Sidekiq Pro](http://sidekiq.org/products/pro).  Each tackles the
problem slightly differently. Sidecloq is inspired by various facets
of these projects, as well as
[resque-scheduler](https://github.com/resque/resque-scheduler). I urge
you to take a look at all of these options to see what works best for
you.

Sidecloq is:

- **Lightweight:** Celluloid is not required.  This coincides well with
  Sidekiq 4, which no longer uses Celluloid.
- **Clean:** Sidecloq leverages only the public API of Sidekiq, and does
  not pollute the Sidekiq namespace.
- **Easy to deploy:** Sidecloq boots with all Sidekiq processes,
  automatically.  Leader election ensures only one process enqueues
  jobs, and a new leader is automatically chosen should the current
  leader die.
- **Easy to configure:** Schedule configuration is done in YAML, using
  the familiar cron syntax. No special DSL or job class mixins required.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sidecloq'
```

Tested on MRI > 2, JRuby and Rubinius.  Basically, if you can run
Sidekiq, you can run Sidecloq.

## Configuration

### Quickstart

Tell Sidecloq where your schedule file is located:

```ruby
Sidecloq.configure do |config|
  config[:schedule_file] = "path/to/myschedule.yml"
end
```
### Rails

If using Rails, and your schedule is located at config/sidecloq.yml,
Sidecloq will find the schedule automatically (ie, you don't have to use
the above configuration block).

## Schedule file format

### Example:

```yaml
my_scheduled_job: # a unique name for this schedule
  class: Jobs::DoWork # the job class
  cron: "* * * * *" # cron formatted schedule
  queue: "queue_name" # Sidekiq queue for job

my_other_scheduled_job:
  class: Jobs::AnotherClassName
  cron: "1 1 * * *"
  queue: "a_different_queue"
```

### Rails

If using Rails, you can nest the schedules under top-level environment
keys, and Sidecloq will select the correct group based on the Rails
environment.  This is useful for development/staging scenarios. For
example:

```yaml
production:
  # these will only run in production
  my_scheduled_job:
    class: Jobs::ClassName
    cron: "* * * * *"
    queue: "queue_name"

staging:
  # this will only run in staging
  my_other_scheduled_job:
    class: Jobs::AnotherClassName
    cron: "1 1 * * *"
    queue: "a_different_queue"
```

## Web Extension

Add Sidecloq::Web after Sidekiq::Web:

```ruby
require 'sidekiq/web'
require 'sidecloq/web'
```

This will add a "Recurring" tab to the sidekiq web ui, where the loaded
schedules are displayed.  You can enqueue a job immediately by clicking
it's corresponding "Enqueue now" button.

![Sidecloq web ui extension screenshot](assets/screenshot.png)

## Notes

If you are running MRI < 2.2.4, you will need to make sure you are using
rack <= 1.5.  You can do this by adding:

```ruby
gem 'rack', '~> 1.5'
```

To your app's Gemfile.

## Contributing

Bug reports and pull requests are welcome.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
