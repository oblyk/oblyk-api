# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def welcome
    @user = params[:user]
    to = %("#{@user.full_name}" <#{@user.email}>)
    I18n.with_locale(@user.language) do
      mail(to: to, subject: t('mailer.welcome.subject', name: @user.first_name))
    end
  end

  def reset_password
    @user = params[:user]
    @token = params[:token]
    to = %("#{@user.full_name}" <#{@user.email}>)
    I18n.with_locale(@user.language) do
      mail(to: to, subject: t('mailer.reset_password.subject'))
    end
  end
end
