# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV['EMAIL_DEFAULT_FROM']
  layout 'mailer'

  before_action :app_url

  private

  def send_with_send_in_blue(to, subject, template)
    # Init Send In Blue instance and Email
    send_in_blue = SibApiV3Sdk::TransactionalEmailsApi.new
    sid_email = SibApiV3Sdk::SendSmtpEmail.new

    # Build content
    html_content = render_to_string template, formats: [:html]
    text_content = render_to_string template, formats: [:text]

    # Set send in blue email parameters
    sid_email.to = [{ email: to }]
    sid_email.subject = subject
    sid_email.html_content = html_content
    sid_email.text_content = text_content
    sid_email.sender = {
      name: ENV['SEND_IN_BLUE_SENDER_NAME'],
      email: ENV['SEND_IN_BLUE_SENDER_EMAIL']
    }
    sid_email.reply_to = {
      email: ENV['SEND_IN_BLUE_REPLY_EMAIL'],
      name: ENV['SEND_IN_BLUE_SENDER_NAME']
    }

    # Send email
    begin
      send_in_blue.send_transac_email(sid_email)
    rescue SibApiV3Sdk::ApiError => e
      Rails.logger.error "Exception when calling TransactionalEmailsApi -> send_transac_email: #{e}"
    end
  end

  def use_send_in_blue?
    ENV['SEND_EMAIL_WITH'] == 'send_in_blue'
  end

  def app_url
    @app_url = Rails.application.config.action_mailer.default_url_options[:host]
  end
end
