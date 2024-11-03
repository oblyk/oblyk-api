# frozen_string_literal: true

class ContestStage < ApplicationRecord
  include StripTagable

  belongs_to :contest
  has_one :gym, through: :contest
  has_many :contest_stage_steps

  before_validation :set_order
  before_validation :normalize_attributes
  after_save :delete_caches
  after_destroy :delete_caches

  validates :climbing_type,
            :stage_order,
            presence: true

  validates :climbing_type, inclusion: { in: [Climb::SPORT_CLIMBING, Climb::BOULDERING, Climb::SPEED_CLIMBING] }
  validates :default_ranking_type, inclusion: { in: ContestRanking::RANKING_TYPE_LIST.freeze }, allow_blank: true

  default_scope { order(:stage_order) }

  def summary_to_json
    Rails.cache.fetch("#{cache_key_with_version}/summary_contest_stage", expires_in: 28.days) do
      {
        id: id,
        climbing_type: climbing_type,
        description: description,
        stage_order: stage_order,
        default_ranking_type: default_ranking_type,
        contest_id: contest_id,
        stage_date: stage_date,
        gym: {
          id: gym.id,
          name: gym.name,
          slug_name: gym.slug_name
        },
        contest: {
          id: contest.id,
          name: contest.name,
          slug_name: contest.slug_name
        }
      }
    end
  end

  def detail_to_json
    summary_to_json.merge(
      {
        contest: contest.summary_to_json,
        contest_stage_steps: contest_stage_steps.map(&:summary_to_json),
        history: {
          created_at: created_at,
          updated_at: updated_at
        }
      }
    )
  end

  private

  def delete_caches
    contest_stage_steps.each(&:delete_summary_cache)
    contest.delete_results_cache
  end

  def set_order
    return unless new_record?

    self.stage_order ||= (contest.contest_stages.order(:stage_order).last&.stage_order || 0) + 1
  end

  def normalize_attributes
    self.description = description&.strip
    self.description = nil if description.blank?
  end
end
