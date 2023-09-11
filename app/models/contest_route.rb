# frozen_string_literal: true

class ContestRoute < ApplicationRecord
  belongs_to :gym_route, optional: true
  belongs_to :contest_route_group
  has_one :contest_stage_step, through: :contest_route_group
  has_many :contest_participant_ascents, dependent: :destroy
  has_many :contest_participant_ascents, dependent: :destroy

  validates :number, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :number_of_holds, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_blank: true

  def disable!
    update_column :disabled_at, DateTime.current
  end

  def enable!
    update_column :disabled_at, nil
  end

  def thumbnail
    return unless gym_route_id
    return unless gym_route.thumbnail.attached?

    gym_route.thumbnail_url
  end

  def summary_to_json
    {
      id: id,
      number: number,
      number_of_holds: number_of_holds,
      disabled_at: disabled_at,
      contest_route_group_id: contest_route_group_id,
      gym_route_id: gym_route_id,
      gym_route: gym_route&.tree_summary,
      thumbnail: thumbnail
    }
  end

  def detail_to_json
    summary_to_json.merge(
      {
        history: {
          created_at: created_at,
          updated_at: updated_at
        }
      }
    )
  end
end
