require 'vault-test-tools'
require 'vault-tools'
require 'rr'
require 'minitest/around/unit'
require 'pry'

ENV['RACK_ENV'] = 'test'
ENV['AWS_REGION'] = 'us-east-1'

module LoggedDataHelper
  def logged_data
    Hash[Scrolls.stream.string.split(/\s+/).map {|p| p.split('=') }]
  end
end

# Overwrite the Rollbar module
module Rollbar
  # A place to store the exceptions
  def self.exceptions
    @exceptions ||= []
  end

  # Store calls to notify in an array instead
  # of calling out to the Rollbar service
  def self.notify(exception, opts = {})
    self.exceptions << [exception, opts]
  end
end

# Clear the stored exceptions in Rollbar
# so each test starts w. a clean slate
module RollbarHelper
  def setup
    super
    Rollbar.exceptions.clear
  end
end

class Vault::TestCase
  include Vault::Test::EnvironmentHelpers
  include RollbarHelper
end

module StubbedS3
  class FakeClient
    def initialize
      @files = {}
    end

    def put_object(opts)
      @files["#{opts[:bucket]}::#{opts[:key]}"] = opts[:body]
    end

    def get_object(opts)
      val = @files["#{opts[:bucket]}::#{opts[:key]}"]
      OpenStruct.new(body: OpenStruct.new(read: val))
    end
  end

  class << self
    def seed(bucket, file, contents)
      fake_client.put_object({bucket: bucket, key: file, body: contents})
    end

    def fake_client
      @client ||= FakeClient.new
    end

    def enable!(opts={}, &block)
      Aws::S3::Client.stub(:new, fake_client) { yield }
    end
  end
end

Vault.setup
