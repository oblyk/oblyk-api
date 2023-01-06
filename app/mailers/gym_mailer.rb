# frozen_string_literal: true

class GymMailer < ApplicationMailer
  def new_request
    @user = params[:user]
    @gym = params[:gym]
    @email = params[:email]
    @justification = params[:justification]
    @name = "#{params[:first_name]} #{params[:last_name]}"
    subject = t('mailer.gym.administration_request.title', gym_name: @gym.name)

    if use_send_in_blue?
      send_with_send_in_blue(ENV['SEND_IN_BLUE_REPLY_EMAIL'], subject, 'gym_mailer/new_request')
    else
      mail(to: ENV['SMTP_USER_NAME'], subject: subject)
    end
  end
end
