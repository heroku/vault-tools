module Vault
  module Tracing
    def self.enabled?
      Config[:zipkin_api_host] && Config[:zipkin_enabled] == 'true'
    end
  end
end
