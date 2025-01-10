# frozen_string_literal: true

class Video < ApplicationRecord
  include ActivityFeedable
  include StripTagable

  belongs_to :user, optional: true
  belongs_to :viewable, polymorphic: true, counter_cache: :videos_count, touch: true
  has_many :reports, as: :reportable, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy

  has_one_attached :video_file

  delegate :latitude, to: :viewable
  delegate :longitude, to: :viewable

  delegate :feed_parent_id, to: :viewable
  delegate :feed_parent_type, to: :viewable
  delegate :feed_parent_object, to: :viewable

  URL_REGEXP = /(youtu\.be|youtube\.com|vimeo\.com|dai\.ly|dailymotion\.com|instagram\.com|tiktok.com)/.freeze
  VIDEO_SERVICES = %w[youtube vimeo dailymotion instagram tiktok oblyk_video].freeze

  before_validation :init_embedded_code

  validates :video_service, presence: true
  validates :viewable_type, inclusion: { in: %w[Crag CragRoute Gym GymRoute].freeze }
  validates :video_service, inclusion: { in: VIDEO_SERVICES }
  validates :url, format: { with: URL_REGEXP }, if: proc { |obj| obj.video_service != 'oblyk_video' }

  validates :video_file, blob: { content_type: :video }, if: proc { |obj| obj.video_service == 'oblyk_video' }

  def valid_url?
    url.match? URL_REGEXP
  end

  def video_file_path
    return nil unless video_service == 'oblyk_video'

    if Rails.application.config.cdn_storage_services.include? Rails.application.config.active_storage.service
      # Use CLOUDFLARE R2 CDN
      "#{ENV['CLOUDFLARE_R2_DOMAIN']}/#{video_file.attachment.key}"

    else
      # Use local active storage
      "#{ENV['OBLYK_API_URL']}#{Rails.application.routes.url_helpers.rails_blob_path(video_file, only_path: true)}"
    end
  end

  def summary_to_json
    detail_to_json
  end

  def detail_to_json
    {
      id: id,
      url: url,
      description: description,
      likes_count: likes_count,
      viewable_type: viewable_type,
      viewable_id: viewable_id,
      viewable: viewable.summary_to_json,
      embedded_code: embedded_code,
      video_service: video_service,
      creator: user&.summary_to_json(with_avatar: true),
      oblyk_video: {
        path: video_file_path,
        content_type: video_service == 'oblyk_video' ? video_file.content_type : nil
      },
      history: {
        created_at: created_at,
        updated_at: updated_at
      }
    }
  end

  def init_embedded_code
    embedded_code_service
  end

  def refresh_embedded_code!
    embedded_code_service
    save
  end

  private

  def embedded_code_service
    if url.blank?
      self.video_service = 'oblyk_video'
      return true
    end

    self.video_service = case url
                         when /(youtube\.com|youtu\.be)/
                           'youtube'
                         when /vimeo\.com/
                           'vimeo'
                         when /(dai\.ly|dailymotion\.com)/
                           'dailymotion'
                         when /(instagram\.com)/
                           'instagram'
                         when /(tiktok\.com)/
                           'tiktok'
                         else
                           nil
                         end
    return unless video_service

    oembed_url = URI::HTTPS.build(
      host: 'iframe.ly',
      path: '/api/oembed',
      query: {
        api_key: ENV['IFRAMELY_API_KEY'],
        url: url
      }.to_query
    )
    resp = Net::HTTP.get_response(oembed_url)
    begin
      data = JSON.parse(resp.body)
      self.embedded_code = data['html']
    rescue JSON::ParserError
      errors.add(:url, 'must_be_valid_video_service')
      false
    end
  end
end
