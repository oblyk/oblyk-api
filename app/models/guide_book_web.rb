# frozen_string_literal: true

class GuideBookWeb < ApplicationRecord
  include ActivityFeedable

  belongs_to :user, optional: true
  belongs_to :crag
  has_many :reports, as: :reportable

  delegate :latitude, to: :crag
  delegate :longitude, to: :crag

  delegate :feed_parent_id, to: :crag
  delegate :feed_parent_type, to: :crag
  delegate :feed_parent_object, to: :crag

  validates :name, :url, presence: true

  def summary_to_json
    JSON.parse(
      ApplicationController.render(
        template: 'api/v1/guide_book_webs/summary.json',
        assigns: { guide_book_web: self }
      )
    )
  end
end
