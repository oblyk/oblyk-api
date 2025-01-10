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

  def new_administrator
    @user = params[:user]
    @host = params[:host]
    @gym = params[:gym]
    @email = params[:requested_email]

    subject = t('mailer.gym.new_administrator.title', gym_name: @gym.name)

    if use_send_in_blue?
      send_with_send_in_blue(@email, subject, 'gym_mailer/new_administrator')
    else
      mail(to: @email, subject: subject)
    end
  end

  def accept_administrator
    @user = params[:user]
    @gym = params[:gym]
    @email = params[:email]

    subject = "#{@gym.name} & Oblyk"

    if use_send_in_blue?
      send_with_send_in_blue(@email, subject, 'gym_mailer/accept_administrator')
    else
      mail(to: @email, subject: subject)
    end
  end

  def weekly_report
    @user = params[:user]
    @figures = params[:figures]
    @start_of_week = params[:start_of_week]
    @end_of_week = params[:end_of_week]

    subject = "Oblyk, rapport du #{I18n.l(@start_of_week)} au #{I18n.l(@end_of_week)}"
    if use_send_in_blue?
      send_with_send_in_blue(@user.email, subject, 'gym_mailer/weekly_report')
    else
      mail(to: @user.email, subject: subject)
    end
  end
end
