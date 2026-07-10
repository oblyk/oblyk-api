# frozen_string_literal: true

class ContestJudgeRoute < ApplicationRecord
  belongs_to :contest_judge
  belongs_to :contest_route
  belongs_to :contest

  before_validation :set_contest

  private

  def set_contest
    self.contest ||= contest_judge.contest
  end
end
