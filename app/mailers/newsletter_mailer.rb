# frozen_string_literal: true

class NewsletterMailer < ApplicationMailer
  def newsletter
    @subscribe = params[:subscribe]
    @newsletter = params[:newsletter]
    to = %("#{@subscribe.email}" <#{@subscribe.email}>)
    mail(to: to, subject: @newsletter.name)
  end
end
