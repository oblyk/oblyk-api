# frozen_string_literal: true

class ContestStageStep < ApplicationRecord
  include Slugable

  belongs_to :contest_stage
  has_one :contest, through: :contest_stage
  has_one :gym, through: :contest
  has_many :contest_route_groups, dependent: :destroy
  has_many :contest_routes, through: :contest_route_groups
  has_many :contest_participant_steps
  has_many :contest_participants, through: :contest_participant_steps

  before_validation :set_order
  after_save :delete_caches
  after_destroy :delete_caches

  validates :name,
            :step_order,
            :ranking_type,
            presence: true

  validates :ranking_type, inclusion: { in: ContestService::Constant::RANKING_TYPE_LIST.freeze }
  validates :ascents_limit, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  def summary_to_json(with_routes: false)
    data = Rails.cache.fetch("#{cache_key_with_version}/summary_contest_stage_step", expires_in: 28.days) do
      {
        id: id,
        name: name,
        slug_name: slug_name,
        step_order: step_order,
        ranking_type: ranking_type,
        ascents_limit: ascents_limit,
        self_reporting: self_reporting,
        default_participants_for_next_step: default_participants_for_next_step,
        contest_stage_id: contest_stage_id,
        contest_route_groups: contest_route_groups.map(&:summary_to_json),
        gym: {
          id: gym.id,
          name: gym.name,
          slug_name: gym.slug_name
        },
        contest: {
          id: contest.id,
          name: contest.name,
          slug_name: contest.slug_name
        },
        contest_stage: {
          id: contest_stage.id,
          climbing_type: contest_stage.climbing_type
        }
      }
    end
    data[:contest_routes] = contest_routes.map(&:summary_to_json) if with_routes
    data
  end

  def detail_to_json
    summary_to_json.merge(
      {
        contest_stage: contest_stage.summary_to_json,
        contest_routes: contest_routes.map(&:summary_to_json),
        history: {
          created_at: created_at,
          updated_at: updated_at
        }
      }
    )
  end

  def delete_summary_cache
    Rails.cache.delete("#{cache_key_with_version}/summary_contest_stage_step")
  end

  private

  def set_order
    return unless new_record?

    self.step_order ||= (contest_stage.contest_stage_steps.order(:step_order).last&.step_order || 0) + 1
  end

  def delete_caches
    contest_routes.each(&:delete_summary_cache)
    contest.delete_results_cache
  end
end
