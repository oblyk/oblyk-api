# frozen_string_literal: true

Rollbar.configure do |config|
  config.access_token = ENV['ROLLBAR_ACCESS_TOKEN']
  config.enabled = %w[production staging].include?(Rails.env)

  config.exception_level_filters.merge!(
    'ActionController::RoutingError' => 'ignore',
    'ActiveRecord::RecordNotFound' => 'ignore'
  )
end
