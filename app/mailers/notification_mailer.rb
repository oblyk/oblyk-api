# frozen_string_literal: true

class NotificationMailer < ApplicationMailer
  def new_message
    @user = params[:user]
    email_notifiable_list = @user.email_notifiable_list.presence || []
    return unless email_notifiable_list.include?('new_message')

    to = %("#{@user.email}" <#{@user.email}>)
    I18n.with_locale(@user.language) do
      mail(to: to, subject: t('mailer.notification.new_message.title'))
    end
  end

  def request_for_follow_up
    @user = params[:user]
    email_notifiable_list = @user.email_notifiable_list.presence || []
    return unless email_notifiable_list.include?('request_for_follow_up')

    @follower = params[:follower]
    to = %("#{@user.email}" <#{@user.email}>)
    I18n.with_locale(@user.language) do
      mail(to: to, subject: t('mailer.notification.request_for_follow_up.title', name: @follower.first_name))
    end
  end

  def new_article
    @user = params[:user]
    email_notifiable_list = @user.email_notifiable_list.presence || []
    return unless email_notifiable_list.include?('new_article')

    @article = params[:article]
    to = %("#{@user.email}" <#{@user.email}>)
    I18n.with_locale(@user.language) do
      mail(to: to, subject: t('mailer.notification.new_article.title'))
    end
  end
end
