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
  scope :no_repetition, -> { where.not(ascent_status: :repetition) }
  scope :lead, -> { where(roping_status: [:lead_climb, :multi_pitch_leader, :multi_pitch_alternate_lead]) }
  scope :noLead, -> { where(roping_status: [:top_rope, :multi_pitch_second]) }
  scope :project, -> { where(ascent_status: :project) }
  scope :on_sight, -> { where(ascent_status: :onsight) }
  scope :by_climbing_type, ->(type) { joins(:crag_route).where(crag_routes: { climbing_type: type }) }
  # scope for uniqueness: keep only the last ascent for each crag_route_id ; base_query arg is for executing this one after the others on resulting ascents
  # requete SQL probablement trop lente -> on utilise donc un Rails uniq dans le modele appelant
  # TODO a supprimer apres confirmation avec Lucien
  # scope :unique_by_crag_route, ->(base_query)  {
  #   where("(crag_route_id, created_at) IN (
  #   SELECT crag_route_id, MAX(created_at)
  #   FROM (#{base_query.to_sql}) AS filtered_results
  #   GROUP BY crag_route_id
  # )")
  # }
  # Combine everything in the `filtered` scope
  scope :filtered, ->(filters) {
    scoped_results = self
    scoped_results = scoped_results.lead if filters[:only_lead_climbs]
    scoped_results = scoped_results.on_sight if filters[:only_on_sight]
    scoped_results = scoped_results.by_climbing_type(filters[:climbing_type_filter]) if filters[:climbing_type_filter] && filters[:climbing_type_filter] != 'all'
    # scoped_results = scoped_results.unique_by_crag_route(scoped_results) if filters[:no_double]
    scoped_results
  }

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
