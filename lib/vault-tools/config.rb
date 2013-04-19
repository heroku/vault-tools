module Vault
  module Config
    extend self

    def remote_env(app, env)
      heroku = Heroku::API.new
      heroku.get_config_vars(app).body[env]
    end

    def core_follower_url
      remote_env('vault-core-follower', 'DATABASE_URL')
    end

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

    def int(key)
      env(key) ? env(key).to_i : nil
    end

    def bool?(key)
      ENV[key] == 'true'
    end

    def sidekiq_concurrency
      int('SIDEKIQ_CONCURRENCY') || 25
    end
  end
end
