# frozen_string_literal: true

class CragRoute < ApplicationRecord
  include SoftDeletable

  has_one_attached :picture
  belongs_to :crag_sector, optional: true
  belongs_to :user, optional: true
  belongs_to :crag
  has_many :comments, as: :commentable
  has_many :links, as: :linkable
  has_many :follows, as: :followable
  has_many :alerts, as: :alertable
  has_many :videos, as: :viewable
  has_many :tags, as: :taggable
  has_many :photos, as: :illustrable

  validates :name, presence: true
  validates :climbing_type, inclusion: { in: Climb::CRAG_LIST }
  validates :incline_type, inclusion: { in: Incline::LIST }, allow_nil: true
  validates :reception_type, inclusion: { in: Reception::LIST }, allow_nil: true
  validates :start_type, inclusion: { in: Start::LIST }, allow_nil: true

  validates :height, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :open_year, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  validate :validate_sections

  before_validation :format_route_section
  before_save :historize_grade_gap
  before_save :historize_sections_count
  before_save :historize_max_bolt

  private

  def format_route_section
    new_sections = []
    single_pitch = Climb.single_pitch?(climbing_type)
    boltable = Climb.boltable?(climbing_type)
    anchorable = Climb.anchorable?(climbing_type)
    receptionable = Climb.receptionable?(climbing_type)
    startable = Climb.startable?(climbing_type)

    sections.each do |section|
      new_sections << {
        climbing_type: single_pitch ? climbing_type : section['climbing_type'] || climbing_type,
        description: !single_pitch ? section['description'] : nil,
        grade: section['grade'],
        grade_value: Grade.to_value(section['grade']),
        height: single_pitch ? height : section['height'],
        bolt_count: boltable ? section['bolt_count'] : nil,
        bolt_type: boltable ? section['bolt_type'] : nil,
        anchor_type: anchorable ? section['anchor_type'] : nil,
        incline_type: section['incline_type'],
        start_type: startable ? start_type : nil,
        reception_type: receptionable ? reception_type : nil
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
    self.sections_count =  sections.count
  end

  def historize_max_bolt
    max_bolt = nil
    sections.each do |section|
      max_bolt = section['bolt_count'] if (section['bolt_count'] || 0) > (max_bolt || 0)
    end
    self.max_bolt = max_bolt
  end

  def validate_sections
    sections.each do |section|
      # valid types
      errors.add(:grade, I18n.t('activerecord.errors.messages.inclusion')) unless Grade.valid? section['grade']
      errors.add(:bolt_type, I18n.t('activerecord.errors.messages.inclusion')) if section['bolt_type'].present? && Bolt::LIST.exclude?(section['bolt_type'])
      errors.add(:start_type, I18n.t('activerecord.errors.messages.inclusion')) if section['start_type'].present? && Bolt::LIST.exclude?(section['start_type'])
      errors.add(:anchor_type, I18n.t('activerecord.errors.messages.inclusion')) if section['anchor_type'].present? && Anchor::LIST.exclude?(section['anchor_type'])
      errors.add(:incline_type, I18n.t('activerecord.errors.messages.inclusion')) if section['incline_type'].present? && Incline::LIST.exclude?(section['incline_type'])
      errors.add(:climbing_type, I18n.t('activerecord.errors.messages.inclusion')) if Climb::CRAG_LIST.exclude?(section['climbing_type'])
      errors.add(:reception_type, I18n.t('activerecord.errors.messages.inclusion')) if section['reception_type'].present? && Reception::LIST.exclude?(section['reception_type'])

      # Valid numerics
      errors.add(:height, I18n.t('activerecord.errors.messages.greater_than')) if section['height'].present? && section['height'].negative?
      errors.add(:bolt_count, I18n.t('activerecord.errors.messages.greater_than')) if section['bolt_count'].present? && section['bolt_count'].negative?
    end
  end
end
