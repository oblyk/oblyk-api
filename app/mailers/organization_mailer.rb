# frozen_string_literal: true

class OrganizationMailer < ApplicationMailer
  def new_organization
    @organization_id = params[:organization_id]
    @name = params[:name]
    @email = params[:email]
    @api_usage_type = params[:api_usage_type]
    mail(to: ENV['SMTP_USER_NAME'], subject: t('mailer.organization.new_organization.title', organization_id: @organization_id))
  end
end
