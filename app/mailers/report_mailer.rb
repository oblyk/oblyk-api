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

    subject = t('mailer.report.new_report.title', report_id: @report_id)
    to = ENV['SMTP_USER_NAME']

    if ENV['SEND_EMAIL_WITH'] == 'send_in_blue'
      html_content = render_to_string('report_mailer/new_report')
      @sid_email = SibApiV3Sdk::SendSmtpEmail.new
      @sid_email.to = [{ email: to }]
      @sid_email.subject = subject
      @sid_email.html_content = html_content
      @sid_email.text_content = ActionView::Base.full_sanitizer.sanitize(html_content)
      @sid_email.sender = {
        name: ENV['SEND_IN_BLUE_SENDER_NAME'],
        email: ENV['SEND_IN_BLUE_SENDER_EMAIL']
      }
      @sid_email.reply_to = {
        email: ENV['SEND_IN_BLUE_REPLY_EMAIL'],
        name: ENV['SEND_IN_BLUE_SENDER_NAME']
      }

      begin
        @send_in_blue.send_transac_email(@sid_email)
      rescue SibApiV3Sdk::ApiError => e
        Rails.logger.error "Exception when calling TransactionalEmailsApi -> send_transac_email: #{e}"
      end
    else
      mail(to: to, subject: subject)
    end
  end
end
