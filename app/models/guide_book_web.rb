# frozen_string_literal: true

class GuideBookWeb < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :crag
  has_many :reports, as: :reportable

  validates :name, :url, presence: true
end
