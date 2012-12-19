require 'uuidtools'

module Vault
  module App
    # Convert an app ID into a v5 UUID.
    #
    # @param app_id [Fixnum] An app ID.
    # @return [String] A v5 UUID that uniquely represents the app.
    def self.id_to_uuid(app_id)
      url = "https://vault.heroku.com/apps/#{app_id}"
      UUIDTools::UUID.sha1_create(UUIDTools::UUID_URL_NAMESPACE, url).to_s
    end

    # Convert a Heroku app ID into a v5 UUID.
    #
    # @param heroku_id [String] A Heroku app ID, such as `app1234@heroku.com`.
    # @raise [RuntimeError] Raised if a malformed Heroku ID is provided.
    # @return [String] A v5 UUID that uniquely represents the app.
    def self.hid_to_uuid(heroku_id)
      if app_id = heroku_id.slice(/^app(\d+)\@heroku\.com$/, 1)
        id_to_uuid(app_id)
      else
        raise "#{heroku_id} is not a valid Heroku app ID."
      end
    end
  end
end
