# frozen_string_literal: true

class GymRouteCover < ApplicationRecord
  include AttachmentResizable

  has_one_attached :picture

  has_many :gym_routes

  validates :picture, blob: { content_type: :image }, allow_nil: true

  def picture_large_url
    resize_attachment picture, '700x700'
  end

  def summary_to_json
    Rails.cache.fetch("#{cache_key_with_version}/summary_gym_route_cover", expires_in: 28.days) do
      {
        id: id,
        picture: picture.attached? ? picture_large_url : nil
      }
    end
  end

  def detail_to_json
    summary_to_json.merge(
      {
        history: {
          created_at: created_at,
          updated_at: updated_at
        }
      }
    )
  end

  def delete_summary_cache
    Rails.cache.delete("#{cache_key_with_version}/summary_gym_route_cover")
  end
end
