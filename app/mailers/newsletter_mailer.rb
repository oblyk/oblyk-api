# frozen_string_literal: true

class NewsletterMailer < ApplicationMailer
  def newsletter
    @subscribe = params[:subscribe]
    @newsletter = params[:newsletter]
    to = %("#{@subscribe.email}" <#{@subscribe.email}>)
    subject = @newsletter.name

    if ENV['SEND_EMAIL_WITH'] == 'send_in_blue'
      html_content = render_to_string('newsletter_mailer/newsletter')
      @sid_email = SibApiV3Sdk::SendSmtpEmail.new
      @sid_email.to = [{ email: to }]
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
      mail(to: to, subject: @newsletter.name)
    end
  end
end
