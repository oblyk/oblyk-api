require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module OblykApi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "Paris"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # Load local env vars
    config.before_configuration do
      env_file = Rails.root.join("config/local_env.yml")
      if File.exist?(env_file)
        YAML.safe_load(File.open(env_file))&.each do |key, value|
          ENV[key.to_s] = value.to_s
        end
      end
    end

    # Added manually session store for sidekiq web
    config.session_store :cookie_store, key: "_interslice_session"
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use config.session_store, config.session_options

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
