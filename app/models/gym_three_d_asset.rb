# frozen_string_literal: true

class GymThreeDAsset < ApplicationRecord
  include Slugable
  include AttachmentResizable
  include StripTagable

  has_one_attached :picture
  has_one_attached :three_d_gltf
  belongs_to :gym, optional: true
  has_many :gym_three_d_elements, dependent: :destroy

  validates :name, presence: true
  validates :picture, blob: { content_type: :image }, allow_nil: true
  validates :three_d_gltf, blob: { content_type: 'model/gltf+json' }, allow_nil: true

  def summary_to_json
    Rails.cache.fetch("#{cache_key_with_version}/summary_gym_three_d_asset", expires_in: 28.days) do
      {
        id: id,
        gym_id: gym_id,
        name: name,
        slug_name: slug_name,
        description: description,
        picture_url: picture.attached? ? picture_large_url : nil,
        picture_thumbnail_url: picture.attached? ? picture_thumbnail_url : nil,
        picture_tiny_thumbnail_url: picture.attached? ? picture_tiny_thumbnail_url : nil,
        three_d_gltf_url: three_d_gltf_url,
        three_d_parameters: three_d_parameters
      }
    end
  end

  def detail_to_json
    summary_to_json
  end

  def three_d?
    three_d_gltf.attached?
  end

  def picture_large_url
    resize_attachment picture, '1920x1920'
  end

  def picture_thumbnail_url
    resize_attachment picture, '300x300'
  end

  def picture_tiny_thumbnail_url
    resize_attachment picture, '100x100'
  end

  def delete_summary_cache
    Rails.cache.delete("#{cache_key_with_version}/summary_gym_three_d_asset")
  end

  def three_d_gltf_url
    return nil unless three_d_gltf.attached?

    if Rails.application.config.cdn_storage_services.include? Rails.application.config.active_storage.service
      "#{ENV['CLOUDFLARE_R2_DOMAIN']}/#{three_d_gltf.attachment.key}"
    else
      "#{ENV['OBLYK_API_URL']}#{Rails.application.routes.url_helpers.polymorphic_url(three_d_gltf.attachment, only_path: true)}"
    end
  end
end
