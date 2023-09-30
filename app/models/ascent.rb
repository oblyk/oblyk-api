# frozen_string_literal: true

class Ascent < ApplicationRecord
  include StripTagable

  belongs_to :user
  belongs_to :climbing_session, optional: true
  belongs_to :color_system_line, optional: true
  belongs_to :crag_route, optional: true
  has_many :ascent_users

  attr_accessor :selected_sections

  before_validation :normalize_blank_values

  validates :released_at, presence: true
  validates :hardness_status, inclusion: { in: Hardness::LIST }, allow_blank: true
  validates :ascent_status, inclusion: { in: AscentStatus::LIST }

  scope :made, -> { where.not(ascent_status: :project) }
  scope :lead, -> { where(roping_status: [:lead_climb, :multi_pitch_leader, :multi_pitch_alternate_lead]) }
  scope :project, -> { where(ascent_status: :project) }

  after_save :attache_to_climbing_session
  after_destroy :purge_climbing_session

  def hardness_value
    return -1 if hardness_status == 'easy_for_the_grade'
    return 0 if hardness_status == 'this_grade_is_accurate'

    1 if hardness_status == 'sandbagged'
  end

  def sections_done
    sections.map { |section| section['index'] }
  end

  private

  def normalize_blank_values
    self.comment = comment&.strip
    self.comment = nil if comment.blank?
  end

  def attache_to_climbing_session
    climbing_session_found = ClimbingSession.find_or_initialize_by session_date: released_at, user_id: user_id

    climbing_session_found.save
    last_climbing_session = climbing_session
    update_column :climbing_session_id, climbing_session_found.id

    last_climbing_session.remove_if_empty! if last_climbing_session && last_climbing_session.id != climbing_session_found.id
  end

  def purge_climbing_session
    climbing_session&.remove_if_empty!
  end
end
