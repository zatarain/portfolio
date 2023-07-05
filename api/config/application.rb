# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Api
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # Amazon Web Services Environment Variables
    config.aws = {
      environment: ENV.fetch('AWS_ENVIRONMENT', nil),
      assume_role: ENV.fetch('AWS_ASSUME_ROLE', nil),
      session_name: ENV.fetch('AWS_SESSION_NAME', nil),
      s3_bucket: "#{ENV.fetch('AWS_ENVIRONMENT', nil)}-cv",
      s3_object: 'index.yml',
    }

    config.instagram = {
      client_id: ENV.fetch('INSTAGRAM_CLIENT_ID', nil),
      client_secret: ENV.fetch('INSTAGRAM_CLIENT_SECRET', nil),
      access_token: ENV.fetch('INSTAGRAM_ACCESS_TOKEN', nil),
      redirect_uri: ENV.fetch('INSTAGRAM_REDIRECT_URI', nil),
    }

    config.curriculum = 'db/cv.yml'
  end
end
