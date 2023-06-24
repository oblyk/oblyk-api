# frozen_string_literal: true

class RockBar < ApplicationRecord
  belongs_to :crag, optional: true
  belongs_to :crag_sector, optional: true

  validates :polyline, presence: true

  def to_geo_json
    {
      type: 'Feature',
      properties: {
        type: 'RockBar',
        id: id,
        crag_id: crag_id,
        sector_id: crag_sector_id,
        icon: nil
      },
      geometry: { type: 'LineString', "coordinates": revers_lat_lng }
    }
  end

  def summary_to_json
    data = {
      id: id,
      polyline: polyline,
      crag_sector_id: crag_sector_id
    }
    if crag
      data[:crag] = {
        id: crag&.id,
        name: crag&.name,
        slug_name: crag&.slug_name
      }
    end
    if crag_sector
      data[:crag_sector] = {
        id: crag_sector&.id,
        name: crag_sector&.name,
        slug_name: crag_sector&.slug_name
      }
    end
    data
  end

  def detail_to_json
    data = summary_to_json
    data[:crag] = crag.summary_to_json
    data[:crag_sector] = crag_sector.summary_to_json if crag_sector
    data.merge(
      {
        history: {
          created_at: created_at,
          updated_at: updated_at
        }
      }
    )
  end

  private

  def revers_lat_lng
    reverse_polyline = []
    polyline.each do |coordinates|
      reverse_polyline << [coordinates[1], coordinates[0]]
    end
    reverse_polyline
  end
end
