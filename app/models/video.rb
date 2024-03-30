# frozen_string_literal: true

class Video < ApplicationRecord
  include ActivityFeedable
  include StripTagable

  belongs_to :user, optional: true
  belongs_to :viewable, polymorphic: true, counter_cache: :videos_count, touch: true
  has_many :reports, as: :reportable, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy

  delegate :latitude, to: :viewable
  delegate :longitude, to: :viewable

  delegate :feed_parent_id, to: :viewable
  delegate :feed_parent_type, to: :viewable
  delegate :feed_parent_object, to: :viewable

  URL_REGEXP = /(youtu\.be|youtube\.com|vimeo\.com|dai\.ly|dailymotion\.com|instagram\.com|tiktok.com)/.freeze
  VIDEO_SERVICES = %w[youtube vimeo dailymotion instagram tiktok].freeze

  before_validation :init_embedded_code

  validates :url, :video_service, presence: true
  validates :viewable_type, inclusion: { in: %w[Crag CragRoute Gym GymRoute].freeze }
  validates :video_service, inclusion: { in: VIDEO_SERVICES }
  validates :url, format: { with: URL_REGEXP }

  def valid_url?
    url.match? URL_REGEXP
  end

  def iframe
    return unless url_for_iframe

    "<iframe src='#{url_for_iframe}' width='100%' height='250px' frameborder='0' />"
  end

  def url_for_iframe
    iframe_url = nil

    case url
    when /(youtube\.com|youtu\.be)/
      video_query = if Addressable::URI.parse(url).query_values.try(:[], 'v')
                      Addressable::URI.parse(url).query_values['v']
                    else
                      Addressable::URI.parse(url).path.split('/').last
                    end
      iframe_url = "https://www.youtube.com/embed/#{video_query}"
    when /vimeo\.com/
      video_query = Addressable::URI.parse(url).path.split('/').last
      iframe_url = "https://player.vimeo.com/video/#{video_query}"
    when /(dai\.ly|dailymotion\.com)/
      video_query = Addressable::URI.parse(url).path.split('/').last
      iframe_url = "https://www.dailymotion.com/embed/video//#{video_query}"
    end
    iframe_url
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
      history: {
        created_at: created_at,
        updated_at: updated_at
      }
    }
  end

  def init_embedded_code
    return unless url_changed?

    embedded_code_service
  end

  def refresh_embedded_code!
    embedded_code_service
    save
  end

  private

  def embedded_code_service
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
