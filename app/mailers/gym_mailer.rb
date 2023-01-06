# frozen_string_literal: true

class GymMailer < ApplicationMailer
  def new_request
    @user = params[:user]
    @gym = params[:gym]
    @email = params[:email]
    @justification = params[:justification]
    @name = "#{params[:first_name]} #{params[:last_name]}"
    subject = t('mailer.gym.administration_request.title', gym_name: @gym.name)

    if ENV['SEND_EMAIL_WITH'] == 'send_in_blue'
      html_content = render_to_string('gym_mailer/new_request')
      @sid_email = SibApiV3Sdk::SendSmtpEmail.new
      @sid_email.to = [{ email: ENV['SEND_IN_BLUE_REPLY_EMAIL'] }]
      @sid_email.subject = subject
      @sid_email.html_content = html_content
      @sid_email.text_content = ActionView::Base.full_sanitizer.sanitize(html_content)
      @sid_email.sender = {
        name: ENV['SEND_IN_BLUE_SENDER_NAME'],
        email: ENV['SEND_IN_BLUE_SENDER_EMAIL']
      }
      @sid_email.reply_to = {
        email: ENV['SEND_IN_BLUE_REPLY_EMAIL'],
        name: ENV['SEND_IN_BLUE_SENDER_NAME']
      }

      begin
        @send_in_blue.send_transac_email(@sid_email)
      rescue SibApiV3Sdk::ApiError => e
        Rails.logger.error "Exception when calling TransactionalEmailsApi -> send_transac_email: #{e}"
      end
    else
      mail(to: ENV['SMTP_USER_NAME'], subject: subject)
    end
  end
end
