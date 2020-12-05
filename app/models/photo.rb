# frozen_string_literal: true

class Photo < ApplicationRecord
  has_one_attached :picture

  belongs_to :user, optional: true
  belongs_to :illustrable, polymorphic: true

  before_validation :init_posted_at

  validates :illustrable_type, inclusion: { in: %w[Crag CragSector CragRoute].freeze }
  validates :picture, blob: { content_type: :image }

  private

  def init_posted_at
    self.posted_at ||= DateTime.current
  end
end
