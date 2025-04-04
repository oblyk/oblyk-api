# frozen_string_literal: true

class ContestWave < ApplicationRecord
  belongs_to :contest

  has_many :contest_participants
  has_many :contest_time_blocks

  validates :name, presence: true

  before_validation :normalize_attributes

  after_save :delete_caches
  after_destroy :delete_caches

  default_scope { order(:name) }

  def summary_to_json
    {
      id: id,
      name: name,
      capacity: capacity,
      contest_id: contest_id,
      contest_participants_count: contest_participants.count
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

  def delete_caches
    contest.contest_categories.each(&:delete_summary_cache)
    contest_participants.each(&:delete_summary_cache)
  end

  private

  def normalize_attributes
    self.capacity = nil if capacity.blank? || capacity.zero?
  end
end
