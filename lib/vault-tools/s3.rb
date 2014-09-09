require 'aws-sdk'

module S3
  extend self

  # Write value to key in S3 bucket, with logging.
  #
  # @param bucket [String]
  # @param key [String]
  # @param value [String]
  def write(bucket, key, value)
    Vault::Log.log(:fn => __method__, :key => key) do
      s3.buckets[bucket].objects[key].write(value)
    end
  end

  # Read value from key in S3 bucket, with logging.
  #
  # @param bucket [String]
  # @param key [String]
  def read(bucket, key)
    Vault::Log.log(:fn => __method__, :key => key) do
      s3.buckets[bucket].objects[key].read
    end
  end

  # Get the underlying AWS::S3 instance, creating it using environment vars
  # if necessary.
  def s3
    @s3 ||= AWS::S3.new(
      :access_key_id => Config.env('AWS_ACCESS_KEY_ID'),
      :secret_access_key => Config.env('AWS_SECRET_ACCESS_KEY'),
      :use_ssl => true
    )
  end

end
