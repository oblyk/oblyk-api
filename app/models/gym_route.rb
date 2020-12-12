# frozen_string_literal: true

class GymRoute < ApplicationRecord
  has_one_attached :picture
  belongs_to :gym_sector, optional: true
  has_one :gym, through: :gym_sector
  has_many :videos, as: :viewable
  has_many :tags, as: :taggable

  validates :name, presence: true
  validates :climbing_type, inclusion: { in: Climb::GYM_LIST }

  validates :height, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  validate :validate_sections

  before_validation :format_route_section
  before_save :historize_grade_gap
  before_save :historize_sections_count

  private

  def format_route_section
    new_sections = []
    single_pitch = Climb.single_pitch?(climbing_type)

    sections.each do |section|
      new_sections << {
        climbing_type: single_pitch ? climbing_type : section['climbing_type'] || climbing_type,
        description: !single_pitch ? section['description'] : nil,
        grade: section['grade'],
        grade_value: Grade.to_value(section['grade']),
        height: single_pitch ? height : section['height']
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

  def validate_sections
    sections.each do |section|
      # valid types
      errors.add(:grade, I18n.t('activerecord.errors.messages.inclusion')) unless Grade.valid? section['grade']

      # Valid numerics
      errors.add(:height, I18n.t('activerecord.errors.messages.greater_than')) if section['height'].present? && section['height'].negative?
    end
  end
end
