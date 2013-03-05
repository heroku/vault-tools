module Vault
  module Config
    extend self

    def env(key)
      ENV[key]
    end

    def env!(key)
      env(key) || raise("missing #{key}")
    end

    def production?
      env('RACK_ENV') == 'production'
    end

    def test?
      env('RACK_ENV') == 'test'
    end

    def app_name
      env("APP_NAME")
    end

    def port
      env!("PORT").to_i
    end

    def database_url(kind = '')
      kind = "#{kind}_".upcase unless kind.empty?
      env!("#{kind}DATABASE_URL")
    end

    def enable_ssl?
      !env('VAULT_TOOLS_DISABLE_SSL')
    end
  end
end
