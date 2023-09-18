# Vault::Tools

Tools is the English word for ツール.  Tooling for the Heroku Vault
team to enable faster bootstrapping for Ruby projects.

[![CircleCI](https://circleci.com/gh/heroku/vault-tools/tree/master.svg?style=shield&circle-token=39ec638ab252a4440ca919f9b09dc258b4459c58)](_https://circleci.com/gh/heroku/vault-tools/tree/master_)

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

## Releasing

    > bundle exec rake release

## Release Notes
  Version 2.2.0 (2023-09-18):
    - Changes syntax for Rollbar helper
    - Bumps rollbar gem version 
    - Unpings rollbar gem version
  Version 2.1.1 (2022-01-06):
    - Added tooling to support metadata tags on request status metrics.
    - Reverted change to minimum supported ruby version.
  Version 2.1.0 (2021-08-26):
    guard-minitest was removed due to it causing problems with the ruby version upgrade. Was not actively used anymore. Hasn't been updated in a long time.
