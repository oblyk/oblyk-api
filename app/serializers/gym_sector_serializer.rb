# frozen_string_literal: true

class GymSectorSerializer < BaseSerializer
  belongs_to :gym_space
  belongs_to :gym

  attributes :id,
             :name,
             :app_path,
             :order,
             :description,
             :group_sector_name,
             :climbing_type,
             :height,
             :polygon,
             :three_d_path,
             :three_d_height,
             :three_d_elevated,
             :gym_space_id,
             :can_be_more_than_one_pitch,
             :min_anchor_number,
             :max_anchor_number,
             :anchor_ranges,
             :anchor,
             :three_d_label_options,
             :linear_metre,
             :developed_metre,
             :category_name,
             :average_opening_time

  attribute :have_three_d_path, &:three_d_path?
end
