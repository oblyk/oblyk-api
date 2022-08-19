# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += %i[password password_confirmation]
Rails.application.config.filter_parameters += %i[httpapiaccesstoken authorization]
Rails.application.config.filter_parameters += %i[token ws_token refresh_token]
