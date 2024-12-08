# frozen_string_literal: true

class ReportMailer < ApplicationMailer
  def new_report
    @report_id = params[:report_id]
    @body = params[:body]
    @reportable_type = params[:reportable_type]
    @reportable_id = params[:reportable_id]
    @report_from_url = params[:report_from_url]
    @user_full_name = params[:user_full_name]
    @user_id = params[:user_id]
    @user_email = params[:user_email]

    subject = t('mailer.report.new_report.title', report_id: @report_id)

    if use_send_in_blue?
      send_with_send_in_blue(ENV['SEND_IN_BLUE_REPLY_EMAIL'], subject, 'report_mailer/new_report')
    else
      mail(to: ENV['SMTP_USER_NAME'], subject: subject)
    end
  end
end
