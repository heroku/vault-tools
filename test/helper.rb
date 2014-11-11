require 'vault-test-tools'
require 'vault-tools'
require 'rr'

ENV['RACK_ENV'] = 'test'

module LoggedDataHelper
  def logged_data
    Hash[Scrolls.stream.string.split(/\s+/).map {|p| p.split('=') }]
  end
end

# Overwrite the Honeybadger module
module Honeybadger
  # A place to store the exceptions
  def self.exceptions
    @exceptions ||= []
  end

  # Store calls to notify in an array instead
  # of calling out to the Honeybadger service
  def self.notify(exception, opts = {})
    self.exceptions << [exception, opts]
  end
end

# Clear the stored exceptions in Honeybadger
# so each test starts w. a clean slate
module HoneybadgerHelper
  def setup
    super
    Honeybadger.exceptions.clear
  end
end

class Vault::TestCase
  include Vault::Test::EnvironmentHelpers
  include HoneybadgerHelper
end

module StubbedS3
  class FakeFile
    def initialize(contents=nil)
      @contents = contents
    end

    def write(contents)
      @contents = contents
    end

    def read
      @contents
    end
  end

  class FakeBucket
    def initialize
      @files = {}
    end

    def [](file_name)
      @files[file_name] ||= FakeFile.new
    end

    def write(file_name, contents)
      @files[file_name].write(contents)
    end

    def objects
      self
    end
  end

  class FakeClient
    def initialize
      @buckets = {}
    end

    def [](bucket_name)
      @buckets[bucket_name] ||= FakeBucket.new
    end

    def buckets
      self
    end
  end

  class << self
    def seed(bucket, file, contents)
      fake_client.buckets[bucket].objects[file].write(contents)
    end

    def fake_client
      @client ||= FakeClient.new
    end

    def enable!(env, opts={})
      AWS.stub!
      expected_aws_args = {
        access_key_id: opts.fetch(:access_key_id, 'FAKE_ID'),
        secret_access_key: opts.fetch(:secret_access_key, 'FAKE_KEY'),
        use_ssl: opts.fetch(:use_ssl, true)
      }
      env.stub(AWS::S3).new(expected_aws_args) { fake_client }
    end
  end
end

Vault.setup
