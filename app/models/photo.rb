# frozen_string_literal: true

class Photo < ApplicationRecord
  include AttachmentResizable
  include StripTagable

  has_one_attached :picture

  belongs_to :user, optional: true
  belongs_to :illustrable, polymorphic: true, counter_cache: :photos_count, touch: true
  has_many :reports, as: :reportable, dependent: :destroy
  has_many :feeds, as: :feedable
  has_many :crag_sectors
  has_many :crags
  has_many :crag_routes
  has_many :areas
  has_many :likes, as: :likeable
  has_many :publication_attachments, as: :attachable, dependent: :destroy

  before_validation :init_posted_at
  after_create_commit :publication_push!

  validates :illustrable_type, inclusion: { in: %w[Crag CragSector CragRoute Article Newsletter].freeze }
  validates :picture, blob: { content_type: :image }

  delegate :longitude, to: :illustrable
  delegate :latitude, to: :illustrable
  delegate :name, to: :illustrable

  def photo_height
    picture.blob.metadata['height']
  end

  def photo_width
    picture.blob.metadata['width']
  end

  def destroyable?
    crag_routes.count.zero? && crag_sectors.count.zero? && crags.count.zero? && areas.count.zero?
  end

  def summary_to_json
    Rails.cache.fetch("#{cache_key_with_version}/summary_photo", expires_in: 28.days) do
      detail_to_json
    end
  end

  def app_path
    "/photos/#{id}"
  end

  def copy
    copies = []
    copies << 'BY' if copyright_by
    copies << 'NC' if copyright_nc
    copies << 'ND' if copyright_nd
    copies.join ' - '
  end

  def detail_to_json
    illustrable_json = {
      type: illustrable_type,
      id: illustrable.id,
      name: illustrable.rich_name,
      slug_name: illustrable.slug_name,
      location: illustrable.location
    }
    if %w[CragSector CragRoute].include? illustrable_type
      illustrable_json[:crag] =
        {
          crag: {
            id: illustrable.crag.id,
            name: illustrable.crag.name,
            slug_name: illustrable.crag.slug_name
          }
        }
    end
    {
      id: id,
      description: description,
      app_path: app_path,
      exif_model: exif_model,
      exif_make: exif_make,
      source: source,
      alt: alt,
      copyright_by: copyright_by,
      copyright_nc: copyright_nc,
      copyright_nd: copyright_nd,
      copy: copy,
      photo_height: photo_height,
      photo_width: photo_width,
      likes_count: likes_count,
      illustrable: illustrable_json,
      creator: user&.summary_to_json(with_avatar: false),
      attachments: {
        picture: attachment_object(picture, "#{illustrable_type}_picture")
      },
      history: {
        created_at: created_at,
        updated_at: updated_at
      }
    }
  end

  def publication_push!(publishable_subject = :new_photo)
    return unless %w[Crag CragRoute CragSector].include?(illustrable_type)

    crag_id = %w[CragRoute CragSector].include?(illustrable_type) ? illustrable.crag_id : illustrable_id

    publication = Publication.includes(:publication_attachments).find_by(
      publishable_id: crag_id,
      publishable_type: 'Crag',
      publishable_subject: publishable_subject,
      published_at: [posted_at.beginning_of_day..posted_at.end_of_day],
      author_id: user_id
    )

    publication ||= Publication.new(
      publishable_id: crag_id,
      publishable_type: 'Crag',
      publishable_subject: publishable_subject,
      generated: true,
      author_id: user_id
    )
    publication.published_at = posted_at
    publication.last_updated_at = posted_at
    publication.publication_attachments << PublicationAttachment.new(attachable_type: 'Photo', attachable_id: id)
    publication.save
  end

  private

  def init_posted_at
    self.posted_at ||= DateTime.current
  end
end
