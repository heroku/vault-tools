# Overwrite the Rollbar module
module Rollbar
  # Store calls to notify in an array instead
  # of calling out to the Rollbar service
  def self.notify(exception, opts = {})
    Rollbar.error(exception, opts)
  end
end
