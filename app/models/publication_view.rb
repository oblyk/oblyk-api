# frozen_string_literal: true

class PublicationView < ApplicationRecord
  belongs_to :user
  belongs_to :publication

  before_create :set_viewed_at

  private

  def set_viewed_at
    self.viewed_at ||= Time.current
  end
end
