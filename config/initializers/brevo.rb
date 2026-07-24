# frozen_string_literal: true

Brevo.configure do |config|
  config.api_key['api-key'] = ENV.fetch('SEND_IN_BLUE_API_KEY', nil)
  config.api_key['partner-key'] = ENV.fetch('SEND_IN_BLUE_API_KEY', nil)
end
