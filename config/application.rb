# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_mailbox/engine'
require 'action_text/engine'
require 'action_view/railtie'
require 'action_cable/engine'
require 'sprockets/railtie'
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module OblykApi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # Allow requests from any domain (cors takes care of that)
    Rails.application.config.hosts = nil

    config.assets.check_precompiled_asset = false

    # Load local env vars
    config.before_configuration do
      env_file = Rails.root.join('config/local_env.yml')
      if File.exist?(env_file)
        YAML.safe_load(File.open(env_file))&.each do |key, value|
          ENV[key.to_s] = value.to_s
        end
      end
    end

    # Added manually session store for sidekiq web
    config.session_store :cookie_store, key: '_interslice_session'
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use config.session_store, config.session_options

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run 'rake -D time' for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Paris'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.available_locales = %i[fr en]
    config.i18n.default_locale = :fr
    config.active_record.default_timezone = :utc

    # JWT second before session expiration (24 * 3600 = 1 day)
    config.jwt_session_lifetime = 24 * 3600

    # Storage services using a CDN
    config.cdn_storage_services = %i[cloudflare mirror mirror_cloudflare_local]
  end
end
