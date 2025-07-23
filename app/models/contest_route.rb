# frozen_string_literal: true

class ContestRoute < ApplicationRecord
  include AttachmentResizable

  has_one_attached :picture
  belongs_to :gym_route, optional: true
  belongs_to :contest_route_group
  has_one :contest_stage_step, through: :contest_route_group
  has_one :contest_stage, through: :contest_stage_step
  has_one :contest, through: :contest_stage
  has_many :contest_participant_ascents, dependent: :destroy
  has_many :contest_participant_ascents, dependent: :destroy
  has_many :contest_judge_routes, dependent: :destroy
  has_many :contest_judges, through: :contest_judge_routes

  validates :number, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :number_of_holds, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_blank: true

  after_save :delete_caches
  after_destroy :delete_caches

  default_scope { order(:number) }

  def disable!
    update_column :disabled_at, DateTime.current
  end

  def enable!
    update_column :disabled_at, nil
  end

  def summary_to_json
    Rails.cache.fetch("#{cache_key_with_version}/summary_contest_route", expires_in: 28.days) do
      {
        id: id,
        number: number,
        name: name,
        number_of_holds: number_of_holds,
        fixed_points: fixed_points,
        additional_zone: additional_zone,
        disabled_at: disabled_at,
        contest_route_group_id: contest_route_group_id,
        gym_route_id: gym_route_id,
        contest_judges: contest_judges.map { |judge| { name: judge.name, id: judge.id } },
        gym_route: gym_route&.tree_summary&.merge(
          {
            gym_space_name: gym_route&.gym_sector&.gym_space&.name,
            gym_sector_name: gym_route&.gym_sector&.name
          }
        ),
        ranking_type: contest_stage_step.ranking_type,
        attachments: {
          gym_route_thumbnail: attachment_object(gym_route&.thumbnail, 'GymRoute_thumbnail'),
          picture: attachment_object(picture)
        }
      }
    end
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

  def delete_summary_cache
    Rails.cache.delete("#{cache_key_with_version}/summary_contest_route")
  end

  private

  def delete_caches
    contest_stage_step.delete_summary_cache
    contest.delete_results_cache
  end
end
