# frozen_string_literal: true

class Video < ApplicationRecord
  include ActivityFeedable
  include StripTagable

  belongs_to :user, optional: true
  belongs_to :viewable, polymorphic: true, counter_cache: :videos_count
  has_many :reports, as: :reportable

  delegate :latitude, to: :viewable
  delegate :longitude, to: :viewable

  delegate :feed_parent_id, to: :viewable
  delegate :feed_parent_type, to: :viewable
  delegate :feed_parent_object, to: :viewable

  URL_REGEXP = %r{(epictv\.com|/youtu\.be|youtube\.com|vimeo\.com|dai\.ly|dailymotion\.com)}.freeze

  validates :url, presence: true
  validates :viewable_type, inclusion: { in: %w[Crag CragRoute Gym GymRoute].freeze }
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
      video_query = if url.match? /embed/
                      Addressable::URI.parse(url).path.split('/').last
                    else
                      Addressable::URI.parse(url).query_values['v']
                    end
      iframe_url = "https://www.youtube.com/embed/#{video_query}"
    when /epictv\.com/
      video_query = Addressable::URI.parse(url).path.split('/').last
      iframe_url = "https://www.epictv.com/player/embed-player/#{video_query}"
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
      viewable_type: viewable_type,
      viewable_id: viewable_id,
      iframe: iframe,
      url_for_iframe: url_for_iframe,
      viewable: viewable.summary_to_json,
      creator: {
        uuid: user&.uuid,
        name: user&.full_name,
        slug_name: user&.slug_name
      },
      history: {
        created_at: created_at,
        updated_at: updated_at
      }
    }
  end
end
