# frozen_string_literal: true

class PublicationAttachment < ApplicationRecord
  belongs_to :publication
  belongs_to :attachable, polymorphic: true

  after_destroy_commit :refresh_count_or_destroy_publication!

  ATTACHABLE_TYPES = %w[
    Crag
    CragSector
    CragRoute
    GuideBookPaper
    GuideBookWeb
    GuideBookPdf
    Article
    Alert
    Photo
    Video
    Gym
    GymRoute
    GymSector
    GymSpace
    Contest
  ].freeze

  validates :attachable_type, inclusion: { in: ATTACHABLE_TYPES }

  def refresh_count_or_destroy_publication!
    if publication.publication_attachments.count.zero? && publication.generated? && publication.body.blank?
      publication.destroy
    else
      publication.refresh_attachment_types_count
      publication.save
    end
  end
end
