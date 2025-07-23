# frozen_string_literal: true

class ContestJudgeRoute < ApplicationRecord
  belongs_to :contest_judge
  belongs_to :contest_route
end
