# frozen_string_literal: true

class ContestTeam < ApplicationRecord
  belongs_to :contest
  has_many :contest_participants

  before_validation :strip_whitespace
  before_destroy :un_team_participants

  validates :name, presence: true
  validates :name, uniqueness: { scope: :contest_id }

  def summary_to_json
    {
      id: id,
      name: name,
      detail_name: detail_name,
      number_of_participants: number_of_participants,
      remaining_places: remaining_places,
      contest_id: contest_id
    }
  end

  def detail_to_json
    summary_to_json.merge(
      {
        contest_participants: contest_participants.map(&:summary_to_json),
        history: {
          created_at: created_at,
          updated_at: updated_at
        }
      }
    )
  end

  def detail_name
    "#{name} (#{number_of_participants}/#{contest.participant_per_team})"
  end

  def number_of_participants
    contest_participants.size
  end

  def remaining_places
    contest.participant_per_team - number_of_participants
  end

  private

  def strip_whitespace
    self.name = name.strip
  end

  def un_team_participants
    contest_participants.each do |participant|
      participant.update contest_team_id: nil
      participant.delete_summary_cache
    end
  end
end
