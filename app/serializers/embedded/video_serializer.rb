# frozen_string_literal: true

module Embedded
  class VideoSerializer < BaseSerializer
    attributes :id,
               :url,
               :description,
               :likes_count,
               :viewable_type,
               :viewable_id,
               :thumbnail_url,
               :embedded_code,
               :video_metadata,
               :video_service

    attribute :oblyk_video do |object|
      {
        path: object.video_file_path,
        content_type: object.video_content_type
      }
    end

    attribute :history do |object|
      {
        created_at: object.created_at,
        updated_at: object.updated_at
      }
    end
  end
end
