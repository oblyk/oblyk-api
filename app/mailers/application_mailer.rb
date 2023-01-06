# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV['EMAIL_DEFAULT_FROM']
  layout 'mailer'

  before_action :app_url, :init_send_in_blue

  private

  def init_send_in_blue
    return if ENV['SEND_EMAIL_WITH'] != 'send_in_blue'

    @send_in_blue = SibApiV3Sdk::TransactionalEmailsApi.new
  end

  def app_url
    @app_url = Rails.application.config.action_mailer.default_url_options[:host]
  end
end
