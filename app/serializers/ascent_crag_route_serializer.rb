# frozen_string_literal: true

class AscentCragRouteSerializer < BaseSerializer
  belongs_to :crag_route
  belongs_to :crag
  belongs_to :user
  has_many :ascent_users, lazy_load_data: true

  attributes :id,
             :ascent_status,
             :roping_status,
             :hardness_status,
             :attempt,
             :crag_route_id,
             :sections,
             :height,
             :note,
             :comment,
             :sections_count,
             :max_grade_value,
             :min_grade_value,
             :max_grade_text,
             :min_grade_text,
             :released_at,
             :private_comment,
             :sections_done

  attribute :history do |object|
    {
      created_at: object.created_at,
      updated_at: object.updated_at
    }
  end
end
