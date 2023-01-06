# frozen_string_literal: true

class NotificationMailer < ApplicationMailer
  def new_message
    @user = params[:user]
    email_notifiable_list = @user.email_notifiable_list.presence || []
    return unless email_notifiable_list.include?('new_message')

    to = %("#{@user.email}" <#{@user.email}>)
    I18n.with_locale(@user.language) do
      subject = t('mailer.notification.new_message.title')
      if ENV['SEND_EMAIL_WITH'] == 'send_in_blue'
        html_content = render_to_string('notification_mailer/new_message')
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
        mail(to: to, subject: subject)
      end
    end
  end

  def request_for_follow_up
    @user = params[:user]
    email_notifiable_list = @user.email_notifiable_list.presence || []
    return unless email_notifiable_list.include?('request_for_follow_up')

    @follower = params[:follower]
    to = %("#{@user.email}" <#{@user.email}>)
    I18n.with_locale(@user.language) do
      subject = t('mailer.notification.request_for_follow_up.title')
      if ENV['SEND_EMAIL_WITH'] == 'send_in_blue'
        html_content = render_to_string('notification_mailer/request_for_follow_up')
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
        mail(to: to, subject: subject)
      end
    end
  end

  def new_article
    @user = params[:user]
    email_notifiable_list = @user.email_notifiable_list.presence || []
    return unless email_notifiable_list.include?('new_article')

    @article = params[:article]
    to = %("#{@user.email}" <#{@user.email}>)
    I18n.with_locale(@user.language) do
      subject = t('mailer.notification.new_article.title')
      if ENV['SEND_EMAIL_WITH'] == 'send_in_blue'
        html_content = render_to_string('notification_mailer/new_article')
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
        mail(to: to, subject: subject)
      end
    end
  end
end
