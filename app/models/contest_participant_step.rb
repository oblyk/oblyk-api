# frozen_string_literal: true

class ContestParticipantStep < ApplicationRecord
  belongs_to :contest_participant
  belongs_to :contest_stage_step
  has_one :contest_category, through: :contest_participant
  has_one :contest, through: :contest_category

  after_save :delete_caches
  after_destroy :delete_caches

  private

  def delete_caches
    contest.delete_results_cache
  end
end
