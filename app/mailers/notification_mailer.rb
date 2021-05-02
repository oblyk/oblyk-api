# frozen_string_literal: true

class NotificationMailer < ApplicationMailer
  def new_message
    @user = params[:user]
    to = %("#{@user.email}" <#{@user.email}>)
    I18n.with_locale(@user.language) do
      mail(to: to, subject: t('mailer.notification.new_message.title'))
    end
  end

  def request_for_follow_up
    @user = params[:user]
    @follower = params[:follower]
    to = %("#{@user.email}" <#{@user.email}>)
    I18n.with_locale(@user.language) do
      mail(to: to, subject: t('mailer.notification.request_for_follow_up.title', name: @follower.first_name))
    end
  end

  def new_article
    @user = params[:user]
    @article = params[:article]
    to = %("#{@user.email}" <#{@user.email}>)
    I18n.with_locale(@user.language) do
      mail(to: to, subject: t('mailer.notification.new_article.title'))
    end
  end
end
