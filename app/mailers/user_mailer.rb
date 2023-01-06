# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def welcome
    @user = params[:user]
    I18n.with_locale(@user.language) do
      to = @user.email
      subject = t('mailer.welcome.subject', name: @user.first_name)
      if use_send_in_blue?
        send_with_send_in_blue(to, subject, 'user_mailer/welcome')
      else
        mail(to: to, subject: subject)
      end
    end
  end

  def reset_password
    @user = params[:user]
    @token = params[:token]
    I18n.with_locale(@user.language) do
      to = @user.email
      subject = t('mailer.reset_password.subject')
      if use_send_in_blue?
        send_with_send_in_blue(to, subject, 'user_mailer/reset_password')
      else
        mail(to: to, subject: subject)
      end
    end
  end
end
