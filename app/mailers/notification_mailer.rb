# frozen_string_literal: true

class NotificationMailer < ApplicationMailer
  def new_message
    @user = params[:user]
    email_notifiable_list = @user.email_notifiable_list.presence || []
    return unless email_notifiable_list.include?('new_message')

    I18n.with_locale(@user.language) do
      to = @user.email
      subject = t('mailer.notification.new_message.title')
      if use_send_in_blue?
        send_with_send_in_blue(to, subject, 'notification_mailer/new_message')
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
    I18n.with_locale(@user.language) do
      to = @user.email
      subject = t('mailer.notification.request_for_follow_up.title')
      if use_send_in_blue?
        send_with_send_in_blue(to, subject, 'notification_mailer/request_for_follow_up')
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
    I18n.with_locale(@user.language) do
      to = @user.email
      subject = t('mailer.notification.new_article.title')
      if use_send_in_blue?
        send_with_send_in_blue(to, subject, 'notification_mailer/new_article')
      else
        mail(to: to, subject: subject)
      end
    end
  end
end
