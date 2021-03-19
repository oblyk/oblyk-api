# frozen_string_literal: true

class Video < ApplicationRecord
  include ActivityFeedable

  belongs_to :user, optional: true
  belongs_to :viewable, polymorphic: true
  has_many :reports, as: :reportable

  delegate :latitude, to: :viewable
  delegate :longitude, to: :viewable

  delegate :feed_parent_id, to: :viewable
  delegate :feed_parent_type, to: :viewable
  delegate :feed_parent_object, to: :viewable

  URL_REGEXP = %r{(epictv\.com|/youtu\.be|youtube\.com|vimeo\.com|dai\.ly|dailymotion\.com)}.freeze

  validates :url, presence: true
  validates :viewable_type, inclusion: { in: %w[Crag CragRoute GymRoute].freeze }
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

    if url.match? /(youtube\.com|youtu\.be)/
      video_query = Addressable::URI.parse(url).query_values['v']
      iframe_url = "https://www.youtube.com/embed/#{video_query}"

    elsif url.match? /epictv\.com/
      video_query = Addressable::URI.parse(url).path.split('/').last
      iframe_url = "https://www.epictv.com/player/embed-player/#{video_query}"

    elsif url.match? /vimeo\.com/
      video_query = Addressable::URI.parse(url).path.split('/').last
      iframe_url = "https://player.vimeo.com/video/#{video_query}"

    elsif url.match? /(dai\.ly|dailymotion\.com)/
      video_query = Addressable::URI.parse(url).path.split('/').last
      iframe_url = "https://www.dailymotion.com/embed/video//#{video_query}"

    end
    iframe_url
  end

  def summary_to_json
    JSON.parse(
      ApplicationController.render(
        template: 'api/v1/videos/summary.json',
        assigns: { video: self }
      )
    )
  end
end
