# frozen_string_literal: true

class Video < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :viewable, polymorphic: true
  has_many :reports, as: :reportable

  URL_REGEXP = %r{(epictv\.com|/youtu\.be|youtube\.com|vimeo\.com|dai\.ly|dailymotion\.com)}.freeze

  validates :url, presence: true
  validates :viewable_type, inclusion: { in: %w[Crag CragSector CragRoute GymRoute].freeze }
  validates :url, format: { with: URL_REGEXP }

  def valid_url?
    url.match? URL_REGEXP
  end

  def iframe
    return unless url_for_iframe

    "<iframe src='#{url_for_iframe}' width='100%' height='150px' frameborder='0' />"
  end

  private

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
end
