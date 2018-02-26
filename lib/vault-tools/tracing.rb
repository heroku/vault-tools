module Vault
  module Tracing
    ZIPKIN_API_HOST_STAGING = 'https://zipkin-staging.heroku.tools'.freeze

    # Injects the zipkin middleware into the Web class, add Zipkin middleware to
    # Excon, and adds Zipkin middleware to Sidekiq.
    #
    # @example
    #   Vault::Tracing.configure
    #
    # @return nil
    def self.configure
      return unless Vault::Tracing.enabled?

      Vault::Web.instance_eval { require 'zipkin-tracer' }
      Vault::Web.use ZipkinTracer::RackHandler, config
      setup_excon
      setup_sidekiq
    end

    # Configuration options for the Zipkin RackHandler.
    #
    # @return [Hash] config options for Zipkin tracer
    def self.config
      {
        service_name: Config.app_name,
        service_port: 443,
        json_api_host: Config[:zipkin_api_host],
        sample_rate: (Config[:zipkin_sample_rate] || 0.1).to_f,
        sampled_as_boolean: false
      }
    end

    # A helper to guard against injecting Zipkin when not desired.
    #
    # @return [true] if so
    def self.enabled?
      Config.app_name &&
        Config[:zipkin_enabled] == 'true' &&
        Config[:zipkin_api_host]
    end

    # Adds ZipkinTracer::ExconHandler to Excon's default middlewares if Excon is
    # defined
    #
    # @private
    #
    # @return nil
    def self.setup_excon
      if add_to_excon_middlewares?
        Excon.defaults[:middlewares].push(ZipkinTracer::ExconHandler)
      end
    end
    private_class_method :setup_excon

    # TODO: add docs
    #
    # @private
    #
    # @return nil
    def self.setup_sidekiq(sidekiq = Sidekiq)
      return unless defined?(sidekiq)
      sidekiq.configure_server do |config|
        config.server_middleware do |chain|
          chain.add ZipkinTracer::Sidekiq::Middleware,
            Vault::Tracing.config.merge(traceable_workers: [:all])
        end
      end
    end

    # Checks to see if Excon is defined and if the Zipkin middleware has already
    # been inserted.
    #
    # @private
    #
    # @return [true] if Excon is defined and the middleware is not already
    # inserted
    def self.add_to_excon_middlewares?
      defined?(Excon) && !Excon.defaults[:middlewares].include?(ZipkinTracer::ExconHandler)
    end
    private_class_method :add_to_excon_middlewares?
  end
end
