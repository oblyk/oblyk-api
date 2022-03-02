# frozen_string_literal: true

class CragRoute < ApplicationRecord
  include SoftDeletable
  include Searchable
  include Slugable
  include ActivityFeedable

  attr_accessor :skip_update_gap_grade

  has_paper_trail only: %i[
    name
    height
    open_year
    opener
    sections
    climbing_type
    incline_type
    reception_type
    start_type
  ], if: proc { |_obj| ENV['PAPER_TRAIL'] == 'true' }

  belongs_to :crag_sector, optional: true, counter_cache: :crag_routes_count, touch: true
  belongs_to :user, optional: true
  belongs_to :photo, optional: true
  belongs_to :crag, counter_cache: :crag_routes_count, touch: true
  has_many :comments, as: :commentable
  has_many :links, as: :linkable
  has_many :alerts, as: :alertable
  has_many :videos, as: :viewable
  has_many :photos, as: :illustrable
  has_many :reports, as: :reportable
  has_many :ascent_crag_routes

  delegate :feed_parent_id, to: :crag
  delegate :feed_parent_type, to: :crag
  delegate :feed_parent_object, to: :crag

  validates :name, presence: true
  validates :climbing_type, inclusion: { in: Climb::CRAG_LIST }
  validates :incline_type, inclusion: { in: Incline::LIST }, allow_nil: true
  validates :reception_type, inclusion: { in: Reception::LIST }, allow_nil: true
  validates :start_type, inclusion: { in: Start::LIST }, allow_nil: true

  validates :height, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :open_year, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  validate :validate_sections

  before_validation :format_route_section
  before_validation :historize_location
  before_save :historize_grade_gap
  before_save :historize_sections_count
  before_save :historize_max_bolt
  after_save :update_gap_grade!

  def rich_name
    "#{grade_to_s} - #{name}"
  end

  def grade_to_s
    if sections_count > 1
      "#{sections_count}L."
    else
      min_grade_text
    end
  end

  def self.search_in_crag(query, crag_id)
    search(query, "CragRoute_in_Crag_#{crag_id}")
  end

  def self.search_in_crag_sector(query, crag_sector_id)
    search(query, "CragRoute_in_CragSector_#{crag_sector_id}")
  end

  def set_location!
    historize_location
    save
  end

  def set_location
    historize_location
  end

  def update_form_ascents!
    ascents_historization = ENV.fetch('CRAG_ROUTE_ASCENTS_HISTORIZATION', 'false')
    return if ascents_historization == 'false'

    ascent_count = nil
    note_count = nil
    sum_note = nil
    hardness_count = nil
    hardness_value = nil
    hardness_votes = nil
    note_votes = nil

    ascent_crag_routes.each do |ascent|
      if ascent.note.present?
        note_count ||= 0
        sum_note ||= 0
        note_votes ||= {}
        note_votes[ascent.note] ||= { count: 0 }
        note_count += 1
        note_votes[ascent.note][:count] += 1
        sum_note += ascent.note
      end

      if ascent.hardness_status.present?
        hardness_count ||= 0
        hardness_value ||= 0
        hardness_votes ||= {}
        hardness_votes[ascent.hardness_status] ||= { count: 0 }

        hardness_count += 1
        hardness_value += ascent.hardness_value
        hardness_votes[ascent.hardness_status][:count] += 1
      end

      if ascent.ascent_status != 'project'
        ascent_count ||= 0
        ascent_count += 1
      end
    end

    self.note = note_count ? sum_note / note_count : nil
    self.note_count = note_count
    self.ascents_count = ascent_count
    self.difficulty_appreciation = hardness_value ? hardness_value.to_d / hardness_count : nil
    self.votes = {
      difficulty_appreciations: hardness_votes,
      notes: note_votes
    }
    save
  end

  def public_ascents
    ascent_crag_routes.where.not(private_comment: true)
  end

  def latitude
    crag_sector&.latitude || crag.latitude
  end

  def longitude
    crag_sector&.longitude || crag.longitude
  end

  def summary_to_json
    Rails.cache.fetch("#{cache_key_with_version}/summary_crag_route") do
      {
        id: id,
        name: name,
        slug_name: slug_name,
        height: height,
        open_year: open_year,
        opener: opener,
        climbing_type: climbing_type,
        sections_count: sections_count,
        max_bolt: max_bolt,
        note: note,
        note_count: note_count,
        ascents_count: ascents_count,
        photos_count: photos_count,
        videos_count: videos_count,
        comments_count: comments_count,
        votes: votes,
        difficulty_appreciation: difficulty_appreciation,
        grade_to_s: grade_to_s,
        grade_gap: {
          max_grade_value: max_grade_value,
          min_grade_value: min_grade_value,
          max_grade_text: max_grade_text,
          min_grade_text: min_grade_text
        },
        crag_sector: crag_sector&.summary_to_json,
        crag: crag&.summary_to_json,
        photo: {
          id: photo&.id,
          url: photo ? photo.large_url : nil,
          thumbnail_url: photo ? photo.thumbnail_url : nil
        }
      }
    end
  end

  def detail_to_json
    summary_to_json.merge(
      {
        versions_count: versions.count,
        sections: sections,
        ascent_comments: public_ascents.map do |ascent|
          {
            comment: ascent.comment,
            note: ascent.note,
            released_at: ascent.released_at,
            creator: ascent.user&.summary_to_json
          }
        end,
        link_count: links.count,
        alert_count: alerts.count,
        creator: user&.summary_to_json,
        history: {
          created_at: created_at,
          updated_at: updated_at
        }
      }
    )
  end

  private

  def search_indexes
    secondary_bucket = crag_sector.present? ? "CragRoute_in_CragSector_#{crag_sector.id}" : nil
    [{ value: name, bucket: "CragRoute_in_Crag_#{crag.id}", secondary_bucket: secondary_bucket }]
  end

  def historize_location
    self.location = [latitude, longitude]
  end

  def format_route_section
    new_sections = []
    single_pitch = Climb.single_pitch?(climbing_type)
    boltable = Climb.boltable?(climbing_type)
    anchorable = Climb.anchorable?(climbing_type)
    receptionable = Climb.receptionable?(climbing_type)
    startable = Climb.startable?(climbing_type)
    sections.each do |section|
      section_height = section['height'].blank? ? nil : section['height'].to_i
      section_bolt_count = section['bolt_count'].blank? ? nil : section['bolt_count'].to_i

      new_sections << {
        climbing_type: single_pitch ? climbing_type : section['climbing_type'] || climbing_type,
        description: !single_pitch ? section['description'] : nil,
        grade: Grade.clean_grade(section['grade']),
        grade_value: Grade.to_value(section['grade']),
        height: single_pitch ? height : section_height,
        bolt_count: boltable ? section_bolt_count : nil,
        bolt_type: boltable ? section['bolt_type'] : nil,
        anchor_type: anchorable ? section['anchor_type'] : nil,
        incline_type: section['incline_type'],
        start_type: startable ? section['start_type'] : nil,
        reception_type: receptionable ? section['reception_type'] : nil,
        tags: section['tags']
      }
    end
    self.sections = new_sections
  end

  def historize_grade_gap
    max_grade_value = Grade::MIN_GRADE
    max_grade_text = ''
    min_grade_value = Grade::MAX_GRADE
    min_grade_text = ''

    sections.each do |section|
      max_grade_text = section['grade'] if section['grade_value'] > max_grade_value
      max_grade_value = section['grade_value'] if section['grade_value'] > max_grade_value

      min_grade_text = section['grade'] if section['grade_value'] < min_grade_value
      min_grade_value = section['grade_value'] if section['grade_value'] < min_grade_value
    end

    self.max_grade_text = max_grade_text
    self.min_grade_text = min_grade_text
    self.max_grade_value = max_grade_value
    self.min_grade_value = min_grade_value
  end

  def historize_sections_count
    self.sections_count = sections.count
  end

  def historize_max_bolt
    max_bolt = nil
    sections.each do |section|
      max_bolt = section['bolt_count'] if (section['bolt_count'] || 0) > (max_bolt || 0)
    end
    self.max_bolt = max_bolt
  end

  def update_gap_grade!
    return if skip_update_gap_grade

    crag.update_gap!
    crag.update_climbing_type!
    crag_sector&.update_gap!
  end

  def validate_sections
    sections.each do |section|
      # valid types
      if section['grade']
        errors.add(:grade, I18n.t('activerecord.errors.messages.inclusion')) unless Grade.valid? section['grade']
      else
        errors.add(:grade, I18n.t('activerecord.errors.messages.required'))
      end

      if section['climbing_type']
        errors.add(:climbing_type, I18n.t('activerecord.errors.messages.inclusion')) if Climb::CRAG_LIST.exclude?(section['climbing_type'])
      else
        errors.add(:climbing_type, I18n.t('activerecord.errors.messages.required'))
      end

      errors.add(:bolt_type, I18n.t('activerecord.errors.messages.inclusion')) if section['bolt_type'].present? && Bolt::LIST.exclude?(section['bolt_type'])
      errors.add(:start_type, I18n.t('activerecord.errors.messages.inclusion')) if section['start_type'].present? && Start::LIST.exclude?(section['start_type'])
      errors.add(:anchor_type, I18n.t('activerecord.errors.messages.inclusion')) if section['anchor_type'].present? && Anchor::LIST.exclude?(section['anchor_type'])
      errors.add(:incline_type, I18n.t('activerecord.errors.messages.inclusion')) if section['incline_type'].present? && Incline::LIST.exclude?(section['incline_type'])
      errors.add(:reception_type, I18n.t('activerecord.errors.messages.inclusion')) if section['reception_type'].present? && Reception::LIST.exclude?(section['reception_type'])

      # Valid numerics
      errors.add(:height, I18n.t('activerecord.errors.messages.greater_than')) if section['height'].present? && section['height'].negative?
      errors.add(:bolt_count, I18n.t('activerecord.errors.messages.greater_than')) if section['bolt_count'].present? && section['bolt_count'].negative?
    end
  end
end
