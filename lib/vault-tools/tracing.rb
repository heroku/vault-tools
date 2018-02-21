module Vault
  module Tracing
    def self.configure
      return unless Vault::Tracing.enabled?
    end

    def self.enabled?
      Config[:zipkin_api_host] && Config[:zipkin_enabled] == 'true'
    end
  end
end
