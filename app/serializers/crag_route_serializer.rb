# frozen_string_literal: true

class CragRouteSerializer < BaseSerializer
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
             :crag_sector_id

  attribute :grade_gap do |object, params|
    if grade_masked?(object, params)
      nil
    else
      {
        max_grade_value: object.max_grade_value,
        min_grade_value: object.min_grade_value,
        max_grade_text: object.max_grade_text,
        min_grade_text: object.min_grade_text
      }
    end
  end

  attribute :masked do |object, params|
    grade_masked?(object, params)
  end

  attribute :grade_to_s do |object, params|
    if grade_masked?(object, params)
      nil
    else
      object.grade_to_s
    end
  end

  attribute :photo do |object|
    {
      id: object.photo&.id,
      attachments: {
        picture: object.attachment_object(object.photo&.picture, "CragRoute_picture")
      }
    }
  end

  def self.grade_masked?(object, params)
    user_level = params[:current_user] ? 1 : 0
    user_level = object.crag.user_crag_declaration.equivalent_level if object.crag.user_crag_declaration
    user_level < object.crag.grade_protection_level
  end
end
