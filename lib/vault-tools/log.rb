module Vault
  module Log
    # Log a count metric.
    #
    # @param name [String] The name of the metric.
    def self.count(name)
      name = "#{Config.app_name}.#{name}" if Config.app_name
      log("count##{name}" => 1)
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
      count("http_#{status}")
      if status_prefix = status.to_s.match(/\d/)[0]
        count("http_#{status_prefix}xx")
      end
    end

    # Log a timing metric.
    #
    # @param name [String] A Sinatra-formatted route URL.
    # @param duration [Fixnum] The duration to record, in seconds or
    #   milliseconds.
    def self.time(name, duration)
      if name
        name.gsub(/\/:\w+/, '').           # Remove param names from path.
             gsub("/", "_").               # Replace slash with underscore.
             gsub(/[^A-Za-z0-9\-\_]/, ''). # Only keep subset of chars.
             slice(1..-1).                 # Strip the leading underscore.
             tap { |name| log("measure##{name}" => "#{duration}ms") }
      end
    end

    # Write a message with key/value pairs to the log stream.
    #
    # @param data [Hash] A mapping of key/value pairs to include in the
    #   output.
    # @param block [Proc] Optionally, a block of code to run before writing
    #   the log message.
    def self.log(data, &block)
      Scrolls.log(data, &block)
    end
  end
end

