# frozen_string_literal: true

class CragRouteSerializer
  include JSONAPI::Serializer

  belongs_to :crag
  belongs_to :crag_sector

  attributes :id,
             :name,
             :slug_name,
             :app_path,
             :height,
             :open_year,
             :opener,
             :climbing_type,
             :sections_count,
             :max_bolt,
             :note,
             :note_count,
             :ascents_count,
             :ascent_users_count,
             :photos_count,
             :videos_count,
             :comments_count,
             :votes,
             :difficulty_appreciation,
             :crag_id,
             :crag_sector_id,
             :grade_to_s

  attribute :grade_gap do |object|
    {
      max_grade_value: object.max_grade_value,
      min_grade_value: object.min_grade_value,
      max_grade_text: object.max_grade_text,
      min_grade_text: object.min_grade_text
    }
  end

  attribute :photo do |object|
    {
      id: object.photo&.id,
      attachments: {
        picture: object.attachment_object(object.photo&.picture, 'CragRoute_picture')
      }
    }
  end
end
