# frozen_string_literal: true

class Alert < ApplicationRecord
  include StripTagable

  belongs_to :user, optional: true
  belongs_to :alertable, polymorphic: true

  has_many :publication_attachments, as: :attachable, dependent: :destroy

  delegate :latitude, to: :alertable
  delegate :longitude, to: :alertable

  ALERT_TYPES_LIST = %w[good warning info bad omega_roc].freeze

  before_validation :init_alerted_at

  validates :description, :alert_type, :alerted_at, presence: true
  validates :alertable_type, inclusion: { in: %w[Crag CragSector CragRoute].freeze }
  validates :alert_type, inclusion: { in: ALERT_TYPES_LIST.freeze }

  after_create :publication_push!

  default_scope { order(alerted_at: :desc) }

  def name
    "#{alert_type} - #{alertable_type}/#{alertable_id}"
  end

  def app_path
    "/alerts/#{id}"
  end

  def summary_to_json
    detail_to_json
  end

  def detail_to_json
    {
      id: id,
      app_path: app_path,
      description: description,
      alert_type: alert_type,
      alerted_at: alerted_at,
      alertable_type: alertable_type,
      alertable_id: alertable_id,
      alertable: alertable.summary_to_json,
      creator: user&.summary_to_json(with_avatar: false),
      history: {
        created_at: created_at,
        updated_at: updated_at
      }
    }
  end

  def publication_push!(publishable_subject = :new_alert)
    return if %w[omega_roc good info].include?(alert_type)

    publication = Publication.new(
      publishable_id: alertable_id,
      publishable_type: alertable_type,
      publishable_subject: publishable_subject,
      published_at: alerted_at,
      last_updated_at: alerted_at,
      generated: true,
      author_id: nil
    )
    publication.publication_attachments << PublicationAttachment.new(
      attachable_type: 'Alert',
      attachable_id: id
    )
    publication.save
  end

  private

  def init_alerted_at
    self.alerted_at ||= Time.current
  end
end
