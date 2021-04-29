# frozen_string_literal: true

require 'sidekiq/web'

host = ENV.fetch('REDIS_HOST', '127.0.0.1')
port = ENV.fetch('REDIS_PORT', '16379')

url = "redis://#{host}:#{port}"
namespace = ENV.fetch('REDIS_NAMESPACE', Rails.env)

Sidekiq.configure_server do |config|
  config.redis = { url: url, namespace: namespace }
end

Sidekiq.configure_client do |config|
  config.redis = { url: url, namespace: namespace }
end
