# Vault::Tools

Tools is the English word for ツール.  Tooling for the Heroku Vault
team to enable faster bootstrapping for Ruby projects.

[![Build Status](https://travis-ci.org/heroku/vault-tools.png?branch=master)](https://travis-ci.org/heroku/vault-tools)

## Installation

Add this line to your application's Gemfile:

    gem 'vault-tools'


## Usage

### `Vault.setup`

calling `Vault.setup` will:

- call `Bundler.require` with the corresponding `RACK_ENV`
- add `./lib` to the `$LOAD_PATH`
- set `TZ` to utc as well as `Sequel`'s default timezone
- overwrite `Time.to_s` to default to ISO8601
- replace Ruby's default, deprecated `Config` with `Vault::Config`
- if the `CONFIG_APP` environment variable is defined and this is
  the production environment, it will attempt to use the Heroku API
  to load the config vars from another app into `Vault::Config`
- enable distributed tracing via Zipkin, if the [required config
  vars](#configs-for-tracing) are set


### `Vault::Config`

Provides a better way to configure the application than simply pulling
strings from `ENV`.

#### defaults

```ruby
Config[:foo]
# => nil

Config.default(:foo, 'bar')
Config[:foo]
# => 'bar'
Config['FOO']
# => 'bar'
```

#### type casts

Returns `nil` when undefined, otherwise casts to indicated type.

```ruby
Config.int(:max_connections)
```

### `Vault::Log`

```ruby
  Log.time(name, t)
  #  => "measure=true at=web-40"

  Log.count('foo')
  #  => "measure=true at=foo"
```

### `Vault::Web`

Sinatra base class

Includes request logging and health endpoints

```ruby
  class Web < Vault::Web
    helpers Vault::SinatraHelpers::HtmlSerializer
  end
```

## Setting up a development environment

Install the dependencies:

    bundle install --binstubs vendor/bin
    rbenv rehash

Run the tests:

    vendor/bin/t

Generate the API documentation:

    vendor/bin/d

## Configs for tracing

The following are config vars to be set in the consumer app for tracing with
Zipkin:
* `APP_NAME` (required) what the trace will show up as in the Zipkin interface.
* `ZIPKIN_ENABLED` (required) must be set to `true` to start tracing.
* `ZIPKIN_API_HOST` (required) where to post traces to. URL must contain the
  basic auth creds from the Tools team.
* `ZIPKIN_SAMPLE_RATE` defaults to `0.1`.

## Releasing

    > bundle exec rake release
