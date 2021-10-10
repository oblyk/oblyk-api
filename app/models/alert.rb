# frozen_string_literal: true

class Alert < ApplicationRecord
  include ActivityFeedable

  belongs_to :user, optional: true
  belongs_to :alertable, polymorphic: true

  delegate :latitude, to: :alertable
  delegate :longitude, to: :alertable

  delegate :feed_parent_id, to: :alertable
  delegate :feed_parent_type, to: :alertable
  delegate :feed_parent_object, to: :alertable

  ALERT_TYPES_LIST = %w[good warning info bad].freeze

  before_validation :init_alerted_at

  validates :description, :alert_type, :alerted_at, presence: true
  validates :alertable_type, inclusion: { in: %w[Crag CragSector CragRoute].freeze }
  validates :alert_type, inclusion: { in: ALERT_TYPES_LIST.freeze }

  default_scope { order(alerted_at: :desc) }

  def summary_to_json
    detail_to_json
  end

  def detail_to_json
    {
      id: id,
      description: description,
      alert_type: alert_type,
      alerted_at: alerted_at,
      alertable_type: alertable_type,
      alertable_id: alertable_id,
      alertable: alertable.summary_to_json,
      creator: {
        uuid: user&.uuid,
        name: user&.full_name,
        slug_name: user&.slug_name
      },
      history: {
        created_at: created_at,
        updated_at: updated_at
      }
    }
  end

  private

  def init_alerted_at
    self.alerted_at ||= Time.current
  end
end
