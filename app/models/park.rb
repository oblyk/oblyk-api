# frozen_string_literal: true

class Park < ApplicationRecord
  include Geolocable
  include Elevable
  include StripTagable
  include AttachmentResizable

  has_one_attached :static_map
  belongs_to :user, optional: true
  belongs_to :crag
  has_many :reports, as: :reportable

  validates :latitude, :longitude, presence: true

  after_save :historize_static_map

  def location
    [latitude, longitude]
  end

  def to_geo_json(minimalistic: false)
    features = {
      type: 'Feature',
      properties: {
        type: 'Park',
        id: id,
        crag_id: crag_id,
        icon: 'park-marker'
      },
      geometry: { type: 'Point', "coordinates": [Float(longitude), Float(latitude), 0.0] }
    }
    unless minimalistic
      features[:properties].merge!(
        {
          description: description,
          crag: {
            id: crag.id,
            name: crag.name,
            slug_name: crag.slug_name
          }
        }
      )
    end
    features
  end

  def summary_to_json
    {
      id: id,
      description: description,
      latitude: latitude,
      longitude: longitude,
      elevation: elevation,
      attachments: {
        static_map: attachment_object(static_map)
      }
    }
  end

  def detail_to_json
    summary_to_json.merge(
      {
        crag: crag.summary_to_json,
        creator: user&.summary_to_json(with_avatar: false),
        history: {
          created_at: created_at,
          updated_at: updated_at
        }
      }
    )
  end

  private

  def historize_static_map
    return unless saved_change_to_latitude? || saved_change_to_longitude?

    HistorizeParkStaticMapWorker.perform_async id
  end
end
