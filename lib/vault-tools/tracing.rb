module Vault
  module Tracing
    ZIPKIN_API_HOST_STAGING = 'https://zipkin-staging.heroku.tools'.freeze

    # Injects the zipkin middleware into the Web class.
    #
    # @example
    #   Vault::Tracing.configure
    #
    # @return nil
    def self.configure
      return unless Vault::Tracing.enabled?

      Vault::Web.instance_eval { require 'zipkin-tracer' }
      Vault::Web.use ZipkinTracer::RackHandler, config
    end

    # Configuration options for the Zipkin RackHandler.
    #
    # @return [Hash] config options for Zipkin tracer
    def self.config
      {
        service_name: "#{Config.app_name}.herokuapp.com",
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
  end
end
