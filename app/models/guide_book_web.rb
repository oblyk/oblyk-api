# frozen_string_literal: true

class GuideBookWeb < ApplicationRecord
  include ActivityFeedable

  belongs_to :user, optional: true
  belongs_to :crag
  has_many :reports, as: :reportable

  delegate :feed_parent_id, to: :crag
  delegate :feed_parent_type, to: :crag

  validates :name, :url, presence: true
end
