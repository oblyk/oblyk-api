# frozen_string_literal: true

class ContestParticipantStep < ApplicationRecord
  belongs_to :contest_participant
  belongs_to :contest_stage_step
  belongs_to :contest

  has_one :contest_category, through: :contest_participant

  before_validation :set_contest
  after_save :delete_caches
  after_destroy :delete_caches

  private

  def set_contest
    self.contest ||= contest_participant.contest
  end

  def delete_caches
    contest.delete_results_cache
  end
end
