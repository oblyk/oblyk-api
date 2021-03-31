# frozen_string_literal: true

class Ascent < ApplicationRecord
  belongs_to :user
  has_many :ascent_users

  validates :released_at, presence: true
  validates :hardness_status, inclusion: { in: Hardness::LIST }, allow_blank: true

  def hardness_value
    return -1 if hardness_status == 'easy_for_the_grade'
    return 0 if hardness_status == 'this_grade_is_accurate'

    1 if hardness_status == 'sandbagged'
  end
end
