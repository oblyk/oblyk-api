# frozen_string_literal: true

require 'sidekiq/web'

host = ENV.fetch('REDIS_HOST', '127.0.0.1')
port = ENV.fetch('REDIS_PORT', '16379')
db = ENV.fetch('REDIS_DB_SIDEKIQ', '12')

url = "redis://#{host}:#{port}/#{db}"
namespace = ENV.fetch('REDIS_NAMESPACE', Rails.env)

Sidekiq.configure_server do |config|
  config.redis = { url: url, namespace: namespace }
end

Sidekiq.configure_client do |config|
  config.redis = { url: url, namespace: namespace }
end
