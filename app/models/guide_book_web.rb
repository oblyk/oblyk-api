# frozen_string_literal: true

class GuideBookWeb < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :crag
  has_many :reports, as: :reportable
  has_many :publication_attachments, as: :attachable, dependent: :destroy

  delegate :latitude, to: :crag
  delegate :longitude, to: :crag

  validates :name, :url, presence: true

  after_create_commit :publication_push!

  def summary_to_json
    detail_to_json
  end

  def detail_to_json
    {
      id: id,
      name: name,
      url: url,
      publication_year: publication_year,
      crag: crag.summary_to_json,
      user: user&.summary_to_json(with_avatar: false),
      history: {
        created_at: created_at,
        updated_at: updated_at
      }
    }
  end

  def publication_push!(publishable_subject = :new_guide_book_web)
    publication = Publication.new(
      publishable_id: crag_id,
      publishable_type: 'Crag',
      publishable_subject: publishable_subject,
      published_at: created_at,
      last_updated_at: created_at,
      generated: true,
      author_id: user_id
    )
    publication.publication_attachments << PublicationAttachment.new(
      attachable_type: 'GuideBookWeb',
      attachable_id: id
    )
    publication.save
  end
end
