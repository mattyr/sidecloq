# Sidecloq

[![Build Status](https://travis-ci.org/mattyr/sidecloq.svg)](https://travis-ci.org/mattyr/sidecloq)
[![Gem Version](https://badge.fury.io/rb/sidecloq.svg)](https://badge.fury.io/rb/sidecloq)
[![Code Climate](https://codeclimate.com/github/mattyr/sidecloq/badges/gpa.svg)](https://codeclimate.com/github/mattyr/sidecloq)
[![Test Coverage](https://codeclimate.com/github/mattyr/sidecloq/badges/coverage.svg)](https://codeclimate.com/github/mattyr/sidecloq/coverage)

Another recurring job extension for Sidekiq.

## Why

TODO: design principles, differences, inspiration (sidetiq,
sidekiq-scheduler, resque-scheduler)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sidecloq'
```

Configure Sidecloq alongside your Sidekiq config.  If using Rails, and
your schedule is located at config/sidecloq.yml, you don't have to do
anything (ie, omit this whole configuration block).

```ruby
Sidcloq.configure do |config|
  config[:schedule_file] =
    File.join(Rails.root, "config/myschedule.yml")
end
```

TODO: configuration options

TODO: schedule file format (like resque-scheduler)

## Web Extension

Add Sidecloq::Web after Sidekiq::Web:

```ruby
require 'sidekiq/web'
require 'sidecloq/web'
```

TODO: screenshot/directions

## Contributing

Bug reports and pull requests are welcome.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

TODO: project links
