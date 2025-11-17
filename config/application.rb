require_relative "boot"

require "rails/all"

# Load environment variables from .env
require 'dotenv/load'

Bundler.require(*Rails.groups)

module SaasProjectApp
  class Application < Rails::Application
    config.load_defaults 8.0
  end
end
