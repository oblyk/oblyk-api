# frozen_string_literal: true

class NewsletterMailer < ApplicationMailer
  def newsletter
    @subscribe = params[:subscribe]
    @newsletter = params[:newsletter]
    to = @subscribe.email
    subject = @newsletter.name

    if use_send_in_blue?
      send_with_send_in_blue(to, subject, 'newsletter_mailer/newsletter')
    else
      mail(to: to, subject: @newsletter.name)
    end
  end
end
