# frozen_string_literal: true

class Alert < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :alertable, polymorphic: true

  ALERT_TYPES_LIST = %w[good warning info bad].freeze

  before_validation :init_alerted_at

  validates :description, :alert_type, :alerted_at, presence: true
  validates :alertable_type, inclusion: { in: %w[Crag CragSector CragRoute].freeze }
  validates :alert_type, inclusion: { in: ALERT_TYPES_LIST.freeze }

  default_scope { order(alerted_at: :desc) }

  private

  def init_alerted_at
    self.alerted_at ||= Time.current
  end
end
