module Vault
  # The StatementStore knows how to save and retrieve invoices from S3
  class StatementStore
    def initialize(opts = {})
      @credentials = Aws::Credentials.new(opts.fetch(:key_id, Config[:aws_access_key_id]),
                                          opts.fetch(:key, Config[:aws_secret_access_key]))
      @region = opts.fetch(:region, Config[:aws_region])
    end

    # Retrieve invoice JSON from S3
    def get_json(opts)
      contents = retrieve(:json, opts)
      begin
        JSON.parse(contents)
      rescue
        contents
      end
    end

    # Write as JSON to S3
    def write_json(opts)
      opts[:contents] = JSON.dump(opts[:contents])
      write(:json, opts)
    end

    # Retrieve invoice HTML from S3
    def get_html(opts)
      retrieve(:html, opts)
    end

    # Write contents as is to HTML bucket on S3
    def write_html(opts)
      write(:html, opts)
    end

    # Retrieve the contents in a given format of a given file from S3
    def retrieve(format, opts)
      s3.get_object({
        bucket: bucket_for(format, opts),
        key: path_for(opts)
      }).body.read
    end

    # Write the contents in the given format to S3
    def write(format, opts)
      s3.put_object({
        bucket: bucket_for(format, opts),
        key: path_for(opts),
        body: opts[:contents]
      })
    end

    # Get an instance of the S3 client to work with
    def s3
      @s3 ||= Aws::S3::Client.new(credentials: @credentials, region: @region)
    end

    # Determine which bucket an invoice should live in
    def bucket_for(format, opts)
      version = opts[:version]
      invoice_bucket = ENV['INVOICE_BUCKET_NAME'] || 'invoice-test'
      if format == :html
        "vault-v#{version}-#{invoice_bucket}"
      else
        "vault-v#{version}-json-#{invoice_bucket}"
      end
    end

    # Determine the path on S3 for the given invoice
    def path_for(opts = {})
      validate_path_opts(opts)
      start = DateTime.parse(opts[:start_time].to_s).strftime('%Y-%m-%d')
      stop = DateTime.parse(opts[:stop_time].to_s).strftime('%Y-%m-%d')
      user_hid = opts[:user_hid] || "user#{opts[:user_id]}@heroku.com"
      sprintf('%s/%s/%s_v%s', start, stop, user_hid, opts[:version])
    end

    private

    def validate_path_opts(opts)
      user = opts[:user_hid] || opts[:user_id]

      fail(ArgumentError, 'start_time required!') unless opts[:start_time]
      fail(ArgumentError, 'stop_time required!') unless opts[:stop_time]
      fail(ArgumentError, 'version required!') unless opts[:version]
      fail(ArgumentError, 'user_hid or or user_id required!') unless user
    end
  end
end
