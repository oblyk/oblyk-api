# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'ekip@oblyk.org'
  layout 'mailer'

  before_action :app_url

  private

  def app_url
    @app_url = Rails.application.config.action_mailer.default_url_options[:host]
  end
end
