# frozen_string_literal: true

class GymMailer < ApplicationMailer
  def new_request
    @user = params[:user]
    @gym = params[:gym]
    @email = params[:email]
    @justification = params[:justification]
    @name = "#{params[:first_name]} #{params[:last_name]}"
    mail(to: ENV['SMTP_USER_NAME'], subject: t('mailer.gym.administration_request.title', gym_name: @gym.name))
  end
end
