require 'helper'

class SomeS3Consumer
  include S3
end

class S3Test < Vault::TestCase
  include LoggedDataHelper

  def around
    set_env 'APP_DEPLOY', 'test'
    set_env 'AWS_ACCESS_KEY_ID', 'fake access key id'
    set_env 'AWS_SECRET_ACCESS_KEY', 'fake secret access key'
    StubbedS3.enable! do
      @consumer = SomeS3Consumer.new
      yield
    end
  end

  def log_output
    Scrolls.stream.string
  end

  # S3 writes should be logged.
  def test_write_logs
    @consumer.write('fake bucket', 'fake key', 'fake value')
    assert_match(/fake key/, log_output)
  end

  # S3 reads should be logged.
  def test_read_logs
    @consumer.read('fake bucket', 'fake key')
    assert_match(/fake key/, log_output)
  end

  # Should use S3 to write to bucket
  def test_writes_to_s3_bucket
    mock(@consumer).s3.mock!.put_object({
      bucket: 'fake bucket',
      key: 'fake key',
      body: 'fake value'
    })
    @consumer.write('fake bucket', 'fake key', 'fake value')
  end

  # Should use S3 to read from bucket
  def test_reads_from_s3_bucket
      #s3.buckets[bucket].objects[key].read
    mock(@consumer).s3.mock!.get_object({
      bucket: 'fake bucket',
      key: 'fake key'
    }).mock!.body.mock!.read
    @consumer.read('fake bucket', 'fake key')
  end
end
