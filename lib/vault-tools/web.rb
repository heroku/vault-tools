require 'vault-tools/log'

module Vault
  # Base class for HTTP API services.
  class Web < Sinatra::Base
    # List of paths that are not protected thus overriding protected!
    set :unprotected_paths, []

    # Work with request id out of the box
    def call(env)
      Thread.current[:request_id] = env['HTTP_X_REQUEST_ID'] || SecureRandom.uuid
      if defined? Excon
        decorate_excon!
        Excon.defaults[:headers]['X-Request-ID'] = Thread.current[:request_id]
      end
      env['HTTP_X_REQUEST_ID'] = Thread.current[:request_id]
      status, headers, response = super(env)
      headers['Request-ID'] = Thread.current[:request_id]
      [status, headers, response]
    end

    def decorate_excon!
      return unless defined? Excon
      begin
        return if Excon.request_id_decorated?
      rescue
        Excon.module_eval do
          def self.request_id_decorated?
            true
          end
        end
        Excon::Connection.class_eval do
          alias :stock_initialize :initialize
          def initialize(params={})
            stock_initialize(params)
            if Excon.defaults[:headers].key? 'X-Request-ID'
              @data[:headers]['X-Request-ID'] ||= Excon.defaults[:headers]['X-Request-ID']
            end
          end
        end
      end
    end

    class << self

      # Store the action for logging purposes.
      def route(verb, action, *)
        condition { @action = action }
        super
      end

      # Create :method:_unprotected methods for instances where default
      # protect! is used
      %w{get put post delete head options path link unlink}.each do |meth|
        define_method "#{meth}_unprotected".to_sym do |path, opts = {}, &block|
          pattern = compile!(meth.upcase, path, block, opts).first
          set :unprotected_paths, settings.unprotected_paths + [pattern]
          if meth.downcase == 'get'
            conditions = @conditions.dup
            route 'GET', path, opts, &block

            @conditions = conditions
            route 'HEAD', path, opts, &block
          else
            route meth.upcase, path, opts, &block
          end
        end
      end
    end

    # HTTP Basic Auth Support
    helpers do
      # Protects an http method.  Returns 401 Not Authorized response
      # when authorized? returns false
      def protected!(*passwords)
        unless unprotected? || authorized?(passwords)
          response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
          throw(:halt, [401, "Not authorized\n"])
        end
      end

      # Check the list of unprotected_paths and see if any of them match
      def unprotected?
        settings.unprotected_paths.any? { |path| path.match(request.path) }
      end

      # Check request for HTTP Basic creds and
      # password matches settings.basic_password
      def authorized?(passwords)
        if passwords.empty?
          passwords = passwords + Array(settings.basic_password)
        end
        passwords << settings.basic_password if passwords.empty?
        @auth ||= Rack::Auth::Basic::Request.new(request.env)
        @auth.provided? && @auth.basic? && @auth.credentials &&
          passwords.include?(@auth.credentials[1])
      end
    end

    # Start timing the request.
    before do
      @start_request = Time.now
    end

    # Log details about the request including how long it took.
    after do
      Log.count_status(response.status)
      Log.time("http.#{@action}", (Time.now - @start_request) * 1000)
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
      Rollbar.notify(e, rack_env: env)
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
    head_unprotected '/' do
      status(200)
    end

    # Determine if the service is running and responding to requests.
    #
    # @method health-check
    # @return The following responses may be returned by this method:
    #
    #   - *HTTP 200 OK*: Returned if the request was successful with `OK` in
    #     the body.
    get_unprotected '/health' do
      [200, 'OK']
    end

    # Trigger an internal server error (to test monitoring and paging tools).
    #
    # @method boom
    # @return The following responses may be returned by this method:
    #
    #   - *HTTP 500 Internal Server Error*: Returned with a traceback in the
    #     body.
    get_unprotected '/boom' do
      raise "An expected error occurred."
    end
  end
end
