module Vault
  module Tracing
    ZIPKIN_API_HOST_STAGING = 'https://zipkin-staging.heroku.tools'.freeze

    def self.configure
      return unless Vault::Tracing.enabled?

      Vault::Web.instance_eval { require 'zipkin-tracer' }
      Vault::Web.use ZipkinTracer::RackHandler, Vault::Tracing.config
    end

    def self.config
      {
        service_name: Config[:app_name],
        service_port: 443,
        json_api_host: Config.default(:zipkin_api_host, ZIPKIN_API_HOST_STAGING),
        sample_rate: Config.default(:zipkin_sample_rate, 0.1),
        sampled_as_boolean: false
      }
    end

    def self.enabled?
      Config[:zipkin_api_host] && Config[:zipkin_enabled] == 'true'
    end
  end
end
