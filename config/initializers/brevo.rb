# frozen_string_literal: true

Brevo.configure do |config|
  config.api_key['api-key'] = ENV["SEND_IN_BLUE_API_KEY"]
  config.api_key['partner-key'] = ENV["SEND_IN_BLUE_API_KEY"]
end
