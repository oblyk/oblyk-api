# frozen_string_literal: true

class GuideBookWeb < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :crag

  validates :name, :url, presence: true
end
