# frozen_string_literal: true

class OrganizationMailer < ApplicationMailer
  def new_organization
    @organization_id = params[:organization_id]
    @name = params[:name]
    @email = params[:email]
    @api_usage_type = params[:api_usage_type]
    subject = t('mailer.organization.new_organization.title', organization_id: @organization_id)
    if use_send_in_blue?
      send_with_send_in_blue(ENV['SEND_IN_BLUE_REPLY_EMAIL'], subject, 'notification_mailer/new_organization')
    else
      mail(to: ENV['SMTP_USER_NAME'], subject: t('mailer.organization.new_organization.title', organization_id: @organization_id))
    end
  end
end
