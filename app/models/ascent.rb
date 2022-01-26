# frozen_string_literal: true

class Ascent < ApplicationRecord
  include StripTagable

  belongs_to :user
  has_many :ascent_users

  attr_accessor :selected_sections

  validates :released_at, presence: true
  validates :hardness_status, inclusion: { in: Hardness::LIST }, allow_blank: true
  validates :ascent_status, inclusion: { in: AscentStatus::LIST }

  scope :made, -> { where.not(ascent_status: :project) }
  scope :project, -> { where(ascent_status: :project) }

  def hardness_value
    return -1 if hardness_status == 'easy_for_the_grade'
    return 0 if hardness_status == 'this_grade_is_accurate'

    1 if hardness_status == 'sandbagged'
  end

  def sections_done
    sections.map { |section| section['index'] }
  end
end
