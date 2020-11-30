# frozen_string_literal: true

# Be sure to restart your server when you modify this file.
namespace = ENV.fetch('REDIS_NAMESPACE', Rails.env)
Rails.application.config.session_store :redis_store, servers: { host: ENV.fetch('REDIS_HOST', '127.0.0.1'),
                                                                port: ENV.fetch('REDIS_PORT', '16379'),
                                                                db: ENV.fetch('REDIS_DB_SESSION', '11'),
                                                                namespace: "#{namespace}_session" },
                                                     expires_in: 120.minutes
