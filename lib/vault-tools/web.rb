require 'vault-tools/log'

module Vault
  # Base class for HTTP API services.
  class Web < Sinatra::Base
    # Store the action for logging purposes.
    def self.route(verb, action, *)
      condition { @action = action }
      super
    end

    # HTTP Basic Auth Support
    helpers do
      # Protects an http method.  Returns 401 Not Authorized response
      # when authorized? returns false
      def protected!
        unless authorized?
          response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
          throw(:halt, [401, "Not authorized\n"])
        end
      end

      # Check request for HTTP Basic creds and
      # password matches settings.basic_password
      def authorized?
        @auth ||=  Rack::Auth::Basic::Request.new(request.env)
        @auth.provided? && @auth.basic? && @auth.credentials &&
          @auth.credentials[1] == settings.basic_password
      end
    end

    # Start timing the request.
    before do
      @start_request = Time.now
    end

    # Log details about the request including how long it took.
    after do
      Log.count_status(response.status)
      Log.time(@action, Time.now - @start_request)
    end

    # Make sure error handler blocks are invoked in tests.
    set :show_exceptions, false
    set :raise_errors, false

    # Require HTTPS connections when production mode is enabled.
    use Rack::SslEnforcer if (Config.enable_ssl? && Config.production?)

    # Return an *HTTP 500 Internal Server Error* with a traceback in the
    # body for easy debugging of errors.
    error do
      e = env['sinatra.error']
      content = "#{e.class}: #{e.message}\n\n"
      content << e.backtrace.join("\n")
      [500, content]
    end

    # Determine if the service is running and responding to requests.
    #
    # @method status-check
    # @return The following responses may be returned by this method:
    #
    #   - *HTTP 200 OK*: Returned if the request was successful.
    head '/' do
      status(200)
    end

    # Determine if the service is running and responding to requests.
    #
    # @method health-check
    # @return The following responses may be returned by this method:
    #
    #   - *HTTP 200 OK*: Returned if the request was successful with `OK` in
    #     the body.
    get '/health' do
      [200, 'OK']
    end

    # Trigger an internal server error (to test monitoring and paging tools).
    #
    # @method boom
    # @return The following responses may be returned by this method:
    #
    #   - *HTTP 500 Internal Server Error*: Returned with a traceback in the
    #     body.
    get '/boom' do
      raise "An expected error occurred."
    end
  end
end
