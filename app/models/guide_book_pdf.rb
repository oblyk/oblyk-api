# frozen_string_literal: true

class GuideBookPdf < ApplicationRecord
  include StripTagable

  has_one_attached :pdf_file
  belongs_to :user, optional: true
  belongs_to :crag
  has_many :reports, as: :reportable
  has_many :publication_attachments, as: :attachable, dependent: :destroy

  delegate :latitude, to: :crag
  delegate :longitude, to: :crag

  validates :name, :pdf_file, presence: true
  validates :pdf_file, blob: { content_type: ['application/pdf'] }

  after_create_commit :publication_push!

  def summary_to_json
    detail_to_json
  end

  def detail_to_json
    {
      id: id,
      name: name,
      description: description,
      author: author,
      publication_year: publication_year,
      pdf_file: pdf_url,
      crag: crag.summary_to_json,
      creator: user&.summary_to_json(with_avatar: false),
      history: {
        created_at: created_at,
        updated_at: updated_at
      }
    }
  end

  def pdf_url
    if Rails.application.config.cdn_storage_services.include? Rails.application.config.active_storage.service
      # Use CLOUDFLARE R2 CDN
      "#{ENV['CLOUDFLARE_R2_DOMAIN']}/#{pdf_file.attachment.key}"

    else
      # Use local active storage
      "#{ENV['OBLYK_API_URL']}#{Rails.application.routes.url_helpers.polymorphic_url(pdf_file, only_path: true)}"
    end
  end

  def publication_push!(publishable_subject = :new_guide_book_pdf)
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
      attachable_type: 'GuideBookPdf',
      attachable_id: id
    )
    publication.save
  end
end
