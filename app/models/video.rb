# frozen_string_literal: true

class Video < ApplicationRecord
  include StripTagable

  belongs_to :user, optional: true
  belongs_to :viewable, polymorphic: true, counter_cache: :videos_count, touch: true
  has_many :reports, as: :reportable, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy
  has_many :publication_attachments, as: :attachable, dependent: :destroy

  has_one_attached :video_file

  delegate :latitude, to: :viewable
  delegate :longitude, to: :viewable

  after_create_commit :publication_push!

  URL_REGEXP = /(youtu\.be|youtube\.com|vimeo\.com|dai\.ly|dailymotion\.com|instagram\.com|tiktok.com)/.freeze
  VIDEO_SERVICES = %w[youtube vimeo dailymotion instagram tiktok oblyk_video].freeze

  before_validation :init_embedded_code

  validates :video_service, presence: true
  validates :viewable_type, inclusion: { in: %w[Crag CragRoute Gym GymRoute].freeze }
  validates :video_service, inclusion: { in: VIDEO_SERVICES }
  validates :url, format: { with: URL_REGEXP }, if: proc { |obj| obj.video_service != 'oblyk_video' }

  validates :video_file, blob: { content_type: :video }, if: proc { |obj| obj.video_service == 'oblyk_video' }

  def name
    id
  end

  def app_path
    "/videos/#{id}"
  end

  def valid_url?
    url.match? URL_REGEXP
  end

  def video_file_path
    return nil unless video_service == 'oblyk_video'

    if Rails.application.config.cdn_storage_services.include? Rails.application.config.active_storage.service
      # Use CLOUDFLARE R2 CDN, AND CONVERT VIDEO IF IS VIDEO/QUICKTIME
      if needs_be_converted?
        "#{ENV['CLOUDFLARE_R2_DOMAIN']}/cdn-cgi/media/mode=video,fit=scale-down,height=1920,width=1920/#{ENV['CLOUDFLARE_R2_DOMAIN']}/#{video_file.attachment.key}"
      else
        "#{ENV['CLOUDFLARE_R2_DOMAIN']}/#{video_file.attachment.key}"
      end

    else
      # Use local active storage
      "#{ENV['OBLYK_API_URL']}#{Rails.application.routes.url_helpers.rails_blob_path(video_file, only_path: true)}"
    end
  end

  def video_content_type
    return nil unless video_service == 'oblyk_video'

    needs_be_converted? ? 'video/mp4' : video_file.content_type
  end

  def summary_to_json
    detail_to_json
  end

  def detail_to_json
    {
      id: id,
      url: url,
      app_path: app_path,
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
        content_type: video_content_type
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

  def convert_to_mp4
    video_file.open(tmpdir: '/tmp') do |file|
      movie = FFMPEG::Movie.new(file.path)
      path = "tmp/video-#{SecureRandom.alphanumeric(12)}.mp4"
      movie.transcode(path, { video_codec: 'libx264', audio_codec: 'aac' })
      video_file.attach(io: File.open(path), filename: "video-#{SecureRandom.alphanumeric(12)}.mp4", content_type: 'video/mp4')
    end
  end

  def publication_push!(publishable_subject = :new_video)
    case viewable_type
    when 'CragRoute'
      publishable_type = 'Crag'
      publishable_id = viewable.crag_id
    when 'CragSector'
      publishable_type = 'Crag'
      publishable_id = viewable.crag_id
    when 'GymRoute'
      publishable_type = 'Gym'
      publishable_id = viewable.gym_sector&.gym_space&.gym_id
    else
      publishable_type = viewable_type
      publishable_id = viewable_id
    end

    return unless publishable_id

    publication = Publication.includes(:publication_attachments).find_by(
      publishable_id: publishable_id,
      publishable_type: publishable_type,
      publishable_subject: publishable_subject,
      published_at: [created_at.beginning_of_week..created_at.end_of_week]
    )

    publication ||= Publication.new(
      publishable_id: publishable_id,
      publishable_type: publishable_type,
      publishable_subject: publishable_subject,
      generated: true
    )
    publication.published_at = created_at
    publication.last_updated_at = created_at
    publication.publication_attachments << PublicationAttachment.new(attachable_type: 'Video', attachable_id: id)
    publication.save
  end

  private

  def needs_be_converted?
    video_service == 'oblyk_video' && video_file.content_type == 'video/quicktime'
  end

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
