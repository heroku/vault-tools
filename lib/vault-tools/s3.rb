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
      s3.put_object({bucket: bucket, key: key, body: value})
    end
  end

  # Read value from key in S3 bucket, with logging.
  #
  # @param bucket [String]
  # @param key [String]
  def read(bucket, key)
    Vault::Log.log(:fn => __method__, :key => key) do
      s3.get_object({bucket: bucket, key: key}).body.read
    end
  end

  # Get the underlying AWS::S3::Client instance, creating it using environment
  # vars if necessary.
  def s3
    @s3 ||= Aws::S3::Client.new(
      credentials: Aws::Credentials.new(Config.env('AWS_ACCESS_KEY_ID'),
                                        Config.env('AWS_SECRET_ACCESS_KEY')),
      region: Config.env('AWS_REGION')
    )
  end

end
