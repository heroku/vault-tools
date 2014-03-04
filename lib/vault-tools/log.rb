module Vault
  module Log
    # Log a count metric.
    #
    # @param name [String] The name of the metric.
    # @param value [Integer] The number of items counted. Can be suffixed with a unit.
    # @param extra_data [Hash] Optional extra data to log.
    def self.count(name, value = 1, extra_data = {})
      log(extra_data.merge("count##{Config.app_name}.#{name}" => value))
    end

    # Log an HTTP status code.  Two log metrics are written each time this
    # method is invoked:
    #
    # - The first one emits a metric called `http_200` for an HTTP 200
    #   response.
    # - The second one emits a metric called `http_2xx` for the same code.
    #
    # This makes it possible to easily measure individual HTTP status codes as
    # well as classes of HTTP status codes.
    #
    # @param status [Fixnum] The HTTP status code to record.
    def self.count_status(status)
      count("http.#{status}")
      if status_prefix = status.to_s.match(/\d/)[0]
        count("http.#{status_prefix}xx")
      end
    end

    # Log a measurement.
    #
    # @param name [String] The name of the metric.
    # @param value [Float] Value for the metric. A unit may be appended.
    # @param extra_data [Hash] Optional extra data to log.
    def self.measure(name, value, extra_data = {})
      log(extra_data.merge("measure##{Config.app_name}.#{name}" => value))
    end

    # Log a timing metric.
    #
    # @param name [String] A Sinatra-formatted route URL.
    # @param duration [Fixnum] The duration to record, in milliseconds.
    def self.time(name, duration)
      if name
        name.gsub(/\/:\w+/, '').            # Remove param names from path.
             gsub(/[\/_]+/, "-").           # Replace slash with dash.
             gsub(/[^A-Za-z0-9\-\_]/, '').  # Only keep subset of chars.
             sub(/^-+/, "").                # Strip the leading dashes.
             tap { |name| measure(name, "#{duration}ms") }
      end
    end

    # Write a message with key/value pairs to the log stream.
    #
    # @param data [Hash] A mapping of key/value pairs to include in the
    #   output.
    # @param block [Proc] Optionally, a block of code to run before writing
    #   the log message.
    def self.log(data, &block)
      data['source'] ||= Config.app_deploy if Config.app_deploy
      data['app'] ||= Config.app_name if Config.app_name
      Scrolls.log(data, &block)
    end
  end
end

