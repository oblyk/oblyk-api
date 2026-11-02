# frozen_string_literal: true

class SprayWallRouteSerializer < BaseSerializer
  belongs_to :spray_wall
  belongs_to :user
  has_many :spray_wall_route_holds, lazy_load_data: true

  attributes :id,
             :name,
             :comment,
             :app_path,
             :styles,
             :level_index,
             :level_length,
             :level_color,
             :grade_text,
             :grade_value,
             :sub_level,
             :sub_level_max,
             :foot_authorization,
             :circus,
             :spray_wall_holds_count,
             :ascents_count,
             :comments_count,
             :likes_count,
             :videos_count

  attribute :current_user do |object, params|
    is_author = params[:current_user]&.id == object.user_id
    can_be_edit = is_author && object.ascents_count.zero?
    {
      is_author: is_author,
      can_be_edit: can_be_edit,
      can_be_destroy: can_be_edit
    }
  end
end
