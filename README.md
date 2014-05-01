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

### Logging

```ruby
  Log.time(name, t)
  #  => "measure=true at=web-40"

  Log.count('foo')
  #  => "measure=true at=foo"
```

### Sinatra base class

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



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Releasing

    > bundle exec rake release
