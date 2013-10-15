require "vault-tools/version"

require 'sinatra/base'
require 'scrolls'
require 'rack/ssl-enforcer'
require 'heroku-api'

module Vault
  #require bundler and the proper gems for the ENV
  def self.require
    Kernel.require 'bundler'
    $stderr.puts "Loading #{ENV['RACK_ENV']} environment..."
    Bundler.require :default, ENV['RACK_ENV'].to_sym
  end

  # adds ./lib dir to the load path
  def self.load_path
    $stderr.puts "Adding './lib' to path..."
    $LOAD_PATH.unshift(File.expand_path('./lib'))
  end

  # sets TZ to UTC and Sequel timezone to :utc
  def self.set_timezones
    $stderr.puts "Setting timezones to UTC..."
    Sequel.default_timezone = :utc if defined? Sequel
    ENV['TZ'] = 'UTC'
  end

  def self.hack_time_class
    $stderr.puts "Modifying Time#to_s to use #iso8601"
    # use send to call private method
    Time.send(:define_method, :to_s) do
      self.iso8601
    end
  end

  # all in one go
  def self.setup
    self.require
    self.load_path
    self.set_timezones
    self.hack_time_class
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
