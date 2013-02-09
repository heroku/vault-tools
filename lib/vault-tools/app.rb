require 'uuidtools'

module Vault
  module App
    # Convert a core app ID into a Heroku app ID.
    #
    # @param app_id [Fixnum] A core app ID.
    # @return [String] A Heroku ID that uniquely represents the app.
    def self.id_to_hid(app_id)
      "app#{app_id}@heroku.com"
    end

    # Convert a core app ID into a v5 UUID.
    #
    # @param app_id [Fixnum] An app ID.
    # @return [String] A v5 UUID that uniquely represents the app.
    def self.id_to_uuid(app_id)
      url = "https://vault.heroku.com/apps/#{app_id}"
      UUIDTools::UUID.sha1_create(UUIDTools::UUID_URL_NAMESPACE, url).to_s
    end

    # Convert a Heroku app ID into a core app ID.
    #
    # @param heroku_id [String] A Heroku app ID, such as `app1234@heroku.com`.
    # @raise [ArgumentError] Raised if a malformed Heroku ID is provided.
    # @return [Fixnum] The core app ID that uniquely represents the app.
    def self.hid_to_id(heroku_id)
      if app_id = heroku_id.slice(/^app(\d+)\@heroku\.com$/, 1)
        app_id.to_i
      else
        raise ArgumentError,"#{heroku_id} is not a valid Heroku app ID."
      end
    end

    # Convert a Heroku app ID into a v5 UUID.
    #
    # @param heroku_id [String] A Heroku app ID, such as `app1234@heroku.com`.
    # @raise [ArgumentError] Raised if a malformed Heroku ID is provided.
    # @return [String] A v5 UUID that uniquely represents the app.
    def self.hid_to_uuid(heroku_id)
      if app_id = heroku_id.slice(/^app(\d+)\@heroku\.com$/, 1)
        id_to_uuid(app_id)
      else
        raise ArgumentError, "#{heroku_id} is not a valid Heroku app ID."
      end
    end
  end
end
