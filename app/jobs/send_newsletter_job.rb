# frozen_string_literal: true

class SendNewsletterJob < ApplicationJob
  queue_as :low

  def perform(subscribe_id, newsletter_id)
    subscribe = Subscribe.find subscribe_id
    newsletter = Newsletter.find newsletter_id
    NewsletterMailer.with(subscribe: subscribe, newsletter: newsletter).newsletter.deliver_now
  end
end
