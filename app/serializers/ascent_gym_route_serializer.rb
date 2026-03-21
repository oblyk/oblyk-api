# frozen_string_literal: true

class AscentGymRouteSerializer < BaseSerializer
  belongs_to :gym_route
  belongs_to :gym
  belongs_to :user
  belongs_to :color_system_line

  attributes :id,
             :ascent_status,
             :roping_status,
             :hardness_status,
             :gym_route_id,
             :gym_grade_level,
             :sections,
             :height,
             :note,
             :comment,
             :ascent_comment,
             :quantity,
             :sections_count,
             :max_grade_value,
             :min_grade_value,
             :max_grade_text,
             :min_grade_text,
             :released_at,
             :private_comment,
             :sections_done,
             :climbing_type,
             :points

  attribute :ascent_comment do |object|
    if object.ascent_comment.present?
      {
        id: object.ascent_comment.id,
        body: object.ascent_comment.body
      }
    end
  end

  attribute :history do |object|
    {
      created_at: object.created_at,
      updated_at: object.updated_at
    }
  end
end
