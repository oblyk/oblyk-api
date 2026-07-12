# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [
  :password, :password_confirmation, :passw, :secret, :token, :ws_token, :refresh_token,
  :_key, :crypt, :salt, :certificate, :otp, :ssn, :httpapiaccesstoken, :authorization
]
