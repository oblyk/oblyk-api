# frozen_string_literal: true

class PublicationAttachment < ApplicationRecord
  belongs_to :publication
  belongs_to :attachable, polymorphic: true

  before_destroy :refresh_publication_count!

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

  def summary_to_json
    {
      id: id,
      attachable: attachable.summary_to_json,
      attachable_type: attachable_type,
      attachable_id: attachable_id
    }
  end

  def refresh_publication_count!
    publication.refresh_attachment_types_count
    publication.save
  end
end
