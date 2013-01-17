require "vault-tools/version"

require 'sinatra/base'
require 'scrolls'

module Vault
  def self.require
    Kernel.require 'bundler'
    STDERR.puts "Loading #{ENV['RACK_ENV']} environment..."
    Bundler.require :default, ENV['RACK_ENV'].to_sym
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
