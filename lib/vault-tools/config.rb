module Vault
  module Config
    @@defaults = {}
    @@shared   = {}

    def self.load_shared!(app = nil)
      heroku   = Heroku::API.new
      @@shared = heroku.get_config_vars(app).body
    end

    def self.shared=(other)
      @@shared = other
    end

    # An environment variable from another app.
    #
    # @param app [String] The name of the app to get the value from.
    # @param name [String] The name of the environment variable to fetch a
    #   value for.
    # @return [String] The value of an environment variable from another
    #   Heroku app or nil if no match is available.
    def self.remote_env(app, name)
      heroku = Heroku::API.new
      heroku.get_config_vars(app).body[name]
    end

    # An environment variable.
    #
    # @param name [String] The name of the environment variable to fetch a
    #   value for.
    # @return [String] The value of the environment variable or nil if no
    #   match is available.
    def self.env(name)
      self[name]
    end

    # Set a default
    # Defaults are supplied when accessing via Config[:varname]
    #
    # @param key [Symbol/String] The lower-case name of the default
    # @return [String] The value of the default
    def self.default(key, value)
      @@defaults[key.to_sym] = value
    end

    # Get all the defaults
    # @return [Hash] The current set of defaults
    def self.defaults
      @@defaults
    end

    # Get a Config value
    # Uses defaults if available.  Converts upper-case ENV var names
    # to lower-case default names.
    #
    # Config[:foo] == nil
    #
    # Config.default(:foo, 'bar')
    # Config[:foo] == 'bar'
    #
    # ENV['FOO'] = 'baz'
    # Config[:foo] == 'baz'
    #
    # @param key [Symbol] The lower-case name of the ENV value
    # @return [String] The value of the ENV value or default.
    def self.[](name)
      var_name = name.to_s.upcase
      default_name = name.to_s.downcase.to_sym
      ENV[var_name] || @@defaults[default_name] || @@shared[var_name]
    end

    # An environment variable.
    #
    # @param name [String] The name of the environment variable to fetch a
    #   value for.
    # @raise [RuntimeError] Raised if the environment variable is not defined.
    # @return [String] The value of the environment variable.
    def self.env!(name)
      self[name] || raise("missing #{name}")
    end

    # The `RACK_ENV` environment variable is used to determine whether the
    # service is in production mode or not.
    #
    # @return [Bool] True if the service is in production mode.
    def self.production?
      self['RACK_ENV'] == 'production'
    end

    # The `RACK_ENV` environment variable is used to determine whether the
    # service is in test mode or not.
    #
    # @return [Bool] True if the service is in test mode.
    def self.test?
      self['RACK_ENV'] == 'test'
    end

    # The `APP_NAME` env var is used to identify which codebase is
    # running in librato.  This usually matches the name of the repository.
    #
    # @return [String] The name of the app
    def self.app_name
      env("APP_NAME")
    end

    # The `APP_DEPLOY` env var is used to identify which deploy of the codebase is
    # running in librato.  This usually matches the name of the environment such
    # as local, production, staging, etc.
    #
    # @return [String] The deploy/environment of the app
    def self.app_deploy
      env("APP_DEPLOY")
    end

    # The port to listen on for web requests.
    #
    # @return [Fixnum] The port to listen on for web requests.
    def self.port
      env!("PORT").to_i
    end

    # The database URL from the environment.
    #
    # @param kind [String] Optionally, the leading name of `*_DATABASE_URL`
    #   environment variable.  Defaults to `DATABASE_URL`.
    # @raise [RuntimeError] Raised if the environment variable is not defined.
    def self.database_url(kind = '')
      kind = "#{kind}_".upcase unless kind.empty?
      env!("#{kind}DATABASE_URL")
    end

    # Enforce HTTPS connections in the web API?
    #
    # @return [Bool] True if SSL is enforced, otherwise false.
    def self.enable_ssl?
      !bool?('VAULT_TOOLS_DISABLE_SSL')
    end

    # An environment variable converted to a Fixnum.
    #
    # @param name [String] The name of the environment variable to fetch a
    #   Fixnum for.
    # @return [Fixnum] The number or nil if the value couldn't be coerced to a
    #   Fixnum.
    def self.int(name)
      self[name] && self[name].to_i
    end

    # Comma-separated words converted to an array.
    #
    # @param name [String] The name of the environment variable to fetch an
    #   array for.
    # @raise [RuntimeError] Raised if the environment variable is not defined.
    # @return [Array] An array of values.
    def self.array(name)
      env(name).to_s.split(',')
    end

    # An environment variable converted to a bool.
    #
    # @param name [String] The name of the environment variable to fetch a
    #   boolean for.
    # @return [bool] True if the value is `true`, otherwise false.
    def self.bool?(name)
      self[name] == 'true'
    end

    # An environment variable converted to a time.
    #
    # @param name [String|Symbol] The name of the environment variable to fetch a
    #   boolean for.
    # @return [Time] Time if the value is parseable, otherwise false.
    def self.time(name)
      if self[name]
        Time.parse(self[name]) rescue Time.utc(*self[name].split('-'))
      end
    end

    def self.uri(name)
      self[name] && URI.parse(self[name])
    end

    # The number of threads to use in Sidekiq workers.
    #
    # @return [Fixnum] The number of threads from the `SIDEKIQ_CONCURRENCY`
    #   environment variable or 25 if no variable is defined.
    def self.sidekiq_concurrency
      int('SIDEKIQ_CONCURRENCY') || 25
    end
  end
end
