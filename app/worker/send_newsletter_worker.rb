# frozen_string_literal: true

class SendNewsletterWorker
  include Sidekiq::Worker
  sidekiq_options queue: :low

  def perform(subscribe_id, newsletter_id)
    subscribe = Subscribe.find subscribe_id
    newsletter = Newsletter.find newsletter_id
    NewsletterMailer.with(subscribe: subscribe, newsletter: newsletter).newsletter.deliver_now
  end
end
