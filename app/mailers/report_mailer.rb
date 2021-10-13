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
    mail(to: ENV['SMTP_USER_NAME'], subject: t('mailer.report.new_report.title', report_id: @report_id))
  end
end
