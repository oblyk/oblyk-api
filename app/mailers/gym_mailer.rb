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

  def email_report
    @user = params[:user]
    @figures = params[:figures]
    @start_date = params[:start_date]
    @end_date = params[:end_date]

    subject = "Oblyk, rapport de #{I18n.l(@start_date, format: :month_and_year)}"
    if use_send_in_blue?
      send_with_send_in_blue(@user.email, subject, 'gym_mailer/email_report')
    else
      mail(to: @user.email, subject: subject)
    end
  end
end
