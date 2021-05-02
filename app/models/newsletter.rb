# frozen_string_literal: true

class Newsletter < ApplicationRecord
  include Slugable

  has_many :photos, as: :illustrable

  validates :name, :body, presence: true

  def rich_name
    name
  end

  def location
    []
  end

  def sent?
    sent_at != nil
  end

  def send_newsletter!
    return if sent?

    update_attribute :sent_at, Time.current

    Subscribe.sendable.find_each do |subscribe|
      SendNewsletterWorker.perform_async(subscribe.id, id)
    end
  end
end
