require "vault-tools/version"

require 'sinatra/base'
require 'scrolls'
require 'rack/ssl-enforcer'
require 'heroku-api'
require 'rollbar'

Rollbar.configure do |config|
  config.environment = ENV['RACK_ENV'] || ENV['RAILS_ENV'] || ENV['APP_ENV'] || ENV['ROLLBAR_ENV'] || 'unassigned'
  config.access_token = ENV['ROLLBAR_ACCESS_TOKEN']
end

# Yes, there's a lot of stuff on STDERR.  But its on
# stderr and not stdout so you can pipe to /dev/null if
# you hate it.  These methods do some pretty heavy-handed
# environment munging and could lead to some hair-pulling
# errors if you're not aware of whats going on.

module Vault
  #require bundler and the proper gems for the ENV
  def self.require
    Kernel.require 'bundler'
    $stderr.puts "Loading #{ENV['RACK_ENV']} environment..."
    Bundler.require :default, ENV['RACK_ENV'].to_sym
  end

  # adds ./lib dir to the load path
  def self.load_path
    $stderr.puts "Adding './lib' to path..." if ENV['DEBUG']
    $LOAD_PATH.unshift(File.expand_path('./lib'))
  end

  # sets TZ to UTC and Sequel timezone to :utc
  def self.set_timezones
    $stderr.puts "Setting timezones to UTC..." if ENV['DEBUG']
    Sequel.default_timezone = :utc if defined? Sequel
    ENV['TZ'] = 'UTC'
  end

  def self.hack_time_class
    $stderr.puts "Modifying Time#to_s to use #iso8601..." if ENV['DEBUG']
    # use send to call private method
    Time.send(:define_method, :to_s) do
      self.iso8601
    end
  end

  def self.override_global_config
    $stderr.puts "Set Config to Vault::Config..." if ENV['DEBUG']
    Object.send(:remove_const, :Config) if defined? Object::Config
    Object.const_set(:Config, Vault::Config)
  end

  def self.load_shared_config
    return unless Config.production?
    if Config[:config_app]
      $stderr.puts "Loading shared config from app: #{Config[:config_app]}..."
      Config.load_shared!(Config[:config_app])
    end
  end

  # all in one go
  def self.setup
    self.require
    self.load_path
    self.set_timezones
    self.hack_time_class
    self.override_global_config
    self.load_shared_config
  end
end

require 'vault-tools/app'
require 'vault-tools/config'
require 'vault-tools/hid'
require 'vault-tools/log'
require 'vault-tools/product'
require 'vault-tools/sinatra_helpers/html_serializer'
require 'vault-tools/user'
require 'vault-tools/web'
require 'vault-tools/pipeline'
require 'vault-tools/text_processor'
require 'vault-tools/time'
require 'vault-tools/s3'
require 'vault-tools/statement_store'
require 'vault-tools/rollbar_helper'
