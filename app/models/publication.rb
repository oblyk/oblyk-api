# frozen_string_literal: true

class Publication < ApplicationRecord
  include StripTagable

  PUBLISHABLE_TYPES = %w[User Crag Gym GuideBookPaper Article].freeze
  PUBLIC_TYPES = %w[Crag Gym GuideBookPaper Article].freeze
  LOCALISABLE_PUBLICATIONS = %w[Crag Gym GuideBookPaper].freeze
  PUBLISHABLE_SUBJECTS = %w[
    new_crag_routes
    create
    new_photo
    new_video
    new_alert
    new_guide_book_web
    new_guide_book_pdf
  ].freeze

  MAX_PUBLICATIONS = {
    'Gym' => 2,
    'User' => 1,
    'Crag' => 1,
    'GuideBookPaper' => 1
  }.freeze

  attr_accessor :viewed

  belongs_to :publishable, polymorphic: true
  belongs_to :author, class_name: 'User', optional: true
  has_many :publication_attachments, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :publication_views, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy

  after_initialize :set_view_if_to_old
  before_validation :normalize_blank_values
  before_save :refresh_attachment_types_count
  before_create :historize_location

  validates :body, presence: true, if: proc { |object| object.published_at.present? && object.publishable_subject.blank? }
  validates :publishable_type, inclusion: { in: PUBLISHABLE_TYPES }
  validates :publishable_subject, inclusion: { in: PUBLISHABLE_SUBJECTS }, allow_blank: true

  def app_path
    "/publications/#{id}"
  end

  def publishable_name
    if %w[User].include? publishable_type
      publishable.full_name
    else
      publishable.name
    end
  end

  def draft
    published_at.blank?
  end

  def avatar_attachment
    if %w[Gym].include? publishable_type
      publishable.attachment_object publishable.logo
    elsif %w[Crag].include? publishable_type
      publishable.attachment_object publishable.photo&.picture
    elsif %w[GuideBookPaper].include? publishable_type
      publishable.attachment_object publishable.cover
    else
      publishable.attachment_object publishable.avatar
    end
  end

  def refresh_attachment_types_count
    types = Hash.new(0)
    publication_attachments.each do |attachment|
      types[attachment.attachable_type] += 1
    end
    self.attachables_count = publication_attachments.size
    self.attachable_types_count = types
  end

  def publish!
    today_publications = Publication.where(
      generated: false,
      publishable_type: publishable_type,
      publishable_id: publishable_id,
      published_at: [DateTime.current.beginning_of_day..DateTime.current.end_of_day]
    )
    today_publications = today_publications.where(author: author) if %w[Crag GuideBookPaper].include? publishable_type

    if today_publications.count >= MAX_PUBLICATIONS[publishable_type]
      errors.add(:base, 'posting_limit_for_today')
      return false
    end

    self.published_at = Time.zone.now
    create_notification! if save
  end

  def published?
    published_at.present?
  end

  def unpublished?
    !published?
  end

  def auto_remove_publication!
    return unless generated

    attachements_count = publication_attachments.size

    if publishable_type == 'Crag' && %w[new_alert new_photo].include?(publishable_subject) && attachements_count.zero?
      destroy
    end
  end

  def create_notification!
    return true if generated
    return true if published_at.blank?

    CreatePublicationNotificationsJob.perform_later(id.to_s)
    true
  end

  private

  def normalize_blank_values
    self.body = body&.strip
    self.body = nil if body.blank?
  end

  def historize_location
    return unless LOCALISABLE_PUBLICATIONS.include?(publishable_type)

    self.latitude = publishable.latitude
    self.longitude = publishable.longitude
  end

  def set_view_if_to_old
    return unless published_at
    return if published_at >= Time.zone.now - 3.months

    self.viewed = true
  end
end
