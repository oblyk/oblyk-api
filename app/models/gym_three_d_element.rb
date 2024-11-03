# frozen_string_literal: true

class GymThreeDElement < ApplicationRecord
  include StripTagable

  belongs_to :gym, optional: true
  belongs_to :gym_space, optional: true
  belongs_to :gym_three_d_asset

  def summary_to_json
    {
      id: id,
      gym_id: gym_id,
      gym_space_id: gym_space_id,
      gym_three_d_asset: gym_three_d_asset.summary_to_json,
      three_d_position: three_d_position,
      three_d_rotation: three_d_rotation,
      three_d_scale: three_d_scale
    }
  end

  def detail_to_json
    summary_to_json
  end
end
