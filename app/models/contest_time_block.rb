# frozen_string_literal: true

class ContestTimeBlock < ApplicationRecord
  belongs_to :contest_wave
  belongs_to :contest_route_group
  has_one :contest, through: :contest_wave

  before_validation :normalize_attributes
  after_save :delete_caches
  after_destroy :delete_caches

  delegate :name, to: :contest_wave

  validates :start_time,
            :end_time,
            presence: true

  def summary_to_json
    {
      id: id,
      name: name,
      start_time: start_time,
      end_time: end_time,
      start_date: start_date,
      end_date: end_date,
      additional_time: additional_time,
      contest_wave_id: contest_wave_id,
      contest_route_group_id: contest_route_group_id
    }
  end

  def detail_to_json
    summary_to_json
  end

  def delete_caches
    contest.contest_categories.each(&:delete_summary_cache)
  end

  private

  def normalize_attributes
    return unless contest.one_day_event?

    self.start_date = contest.start_date
    self.end_date = contest.end_date
  end
end
