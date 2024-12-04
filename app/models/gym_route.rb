# frozen_string_literal: true

class GymRoute < ApplicationRecord
  include AttachmentResizable
  include StripTagable

  has_one_attached :thumbnail
  belongs_to :gym_route_cover, optional: true
  belongs_to :gym_sector, optional: true
  belongs_to :gym_grade_line, optional: true # TODO : DELETE AFTER MIGRATION
  has_one :gym_space, through: :gym_sector
  has_one :gym, through: :gym_sector
  has_many :videos, as: :viewable
  has_many :ascent_gym_routes
  has_many :gym_route_openers
  has_many :gym_openers, through: :gym_route_openers
  has_many :likes, as: :likeable
  has_many :contest_routes
  has_many :comments, as: :commentable

  delegate :feed_parent_id, to: :gym
  delegate :feed_parent_type, to: :gym
  delegate :feed_parent_object, to: :gym

  validates :opened_at, presence: true
  validates :climbing_type, inclusion: { in: Climb::GYM_LIST }
  validates :height, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :anchor_number, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate :validate_sections

  validates :thumbnail, blob: { content_type: :image }, allow_nil: true

  before_validation :format_route_section
  before_validation :normalize_blank_values
  before_validation :historize_level_information
  before_save :historize_grade_gap
  before_save :historize_sections_count
  after_update :delete_contest_route_cache

  scope :dismounted, -> { where.not(dismounted_at: nil) }
  scope :mounted, -> { where(dismounted_at: nil) }

  accepts_nested_attributes_for :gym_route_cover
  attr_accessor :qrcode

  # TODO: DELETE AFTER MIGRATION
  def gym_grade_line
    GymGradeLine.unscoped { super }
  end

  # TODO: DELETE AFTER MIGRATION
  def gym_grade
    gym_grade_line&.gym_grade || gym_sector.gym_grade
  end

  def calculated_point(for_gym = nil)
    if points
      point = points
    else
      gym = for_gym.presence || self.gym
      point_system = case climbing_type
                     when 'sport_climbing'
                       gym.sport_climbing_ranking
                     when 'bouldering'
                       # binding.pry if gym_sector.blank?
                       gym.boulder_ranking
                     else
                       gym.pan_ranking
                     end
      point = case point_system
              when 'division'
                ascents_count = self.ascents_count&.positive? ? self.ascents_count : 1
                1000 / ascents_count
              when 'point_by_grade'
                min_grade_value ? (2000 * 0.85**(49 - min_grade_value)).round : 0
              else
                points
              end
    end
    point
  end

  def points_to_s
    calculated_point
  end

  def grade_to_s
    return '' unless grade_system

    if sections_count > 1
      sections_array = []
      sections.each do |section|
        sections_array << section['grade']
      end
      sections_array.join(', ')
    else
      min_grade_text
    end
  end

  def tags
    tags = []
    sections.each do |section|
      tags += section.try(:[], 'tags') || []
    end
    tags
  end

  def styles
    styles = []
    sections.each do |section|
      styles += section.try(:[], 'styles') || []
    end
    styles
  end

  def grade_system
    gym.gym_levels.find_by(climbing_type: climbing_type)&.grade_system
  end

  def mounted?
    dismounted_at.blank?
  end

  def dismounted?
    dismounted_at.present?
  end

  def dismount!
    self.dismounted_at = Time.zone.now
    save
  end

  def mount!
    self.dismounted_at = nil
    save
  end

  def picture_large_url
    resize_attachment gym_route_cover.picture, '700x700'
  end

  def thumbnail_url
    resize_attachment thumbnail, '300x300'
  end

  def app_path
    "#{ENV['OBLYK_APP_URL']}/gyms/#{gym.id}/#{gym.slug_name}/spaces/#{gym_space.id}/#{gym_space.slug_name}?route=#{id}"
  end

  def short_app_path
    "#{ENV['OBLYK_APP_URL']}/gr/#{gym.id}-#{id}"
  end

  def hold_gradiant
    gradiant(hold_colors, fluid: true)
  end

  def tag_gradiant
    gradiant(tag_colors, fluid: false)
  end

  def update_form_ascents!
    ascent_count = 0
    hardness_count = nil
    hardness_value = nil
    hardness_votes = nil
    user_ids = []

    ascent_gym_routes.select(:hardness_status, :ascent_status, :user_id).each do |ascent|
      next if %w[project repetition].include? ascent.ascent_status
      next if user_ids.include? ascent.user_id

      user_ids << ascent.user_id

      ascent_count ||= 0
      ascent_count += 1

      next if ascent.hardness_status.blank?

      hardness_count ||= 0
      hardness_value ||= 0
      hardness_votes ||= {}
      hardness_votes[ascent.hardness_status] ||= { count: 0 }

      hardness_count += 1
      hardness_value += ascent.hardness_value
      hardness_votes[ascent.hardness_status][:count] += 1
    end

    self.ascents_count = ascent_count
    self.difficulty_appreciation = hardness_value ? hardness_value.to_d / hardness_count : nil
    self.votes = {
      difficulty_appreciations: hardness_votes
    }
    save
  end

  def tree_summary
    Rails.cache.fetch("#{cache_key_with_version}/tree_summary_gym_route", expires_in: 28.days) do
      {
        id: id,
        name: name,
        hold_colors: hold_colors,
        tag_colors: tag_colors,
        sections: sections,
        sections_count: sections_count,
        points: points,
        points_to_s: points_to_s,
        grade_to_s: grade_to_s,
        thumbnail: thumbnail.attached? ? thumbnail_url : nil,
        anchor_number: anchor_number,
        gym_id: gym.id,
        gym_space_id: gym_space.id,
        grade_gap: {
          max_grade_value: max_grade_value,
          min_grade_value: min_grade_value,
          max_grade_text: max_grade_text,
          min_grade_text: min_grade_text
        }
      }
    end
  end

  def summary_to_json
    Rails.cache.fetch("#{cache_key_with_version}/summary_gym_route", expires_in: 28.days) do
      {
        id: id,
        name: name,
        height: height,
        description: description,
        climbing_type: climbing_type,
        openers: gym_openers.map(&:summary_to_json),
        gym_opener_ids: gym_openers.map(&:id),
        opened_at: opened_at,
        dismounted_at: dismounted_at,
        polyline: polyline,
        hold_colors: hold_colors,
        tag_colors: tag_colors,
        sections: sections,
        difficulty_appreciation: difficulty_appreciation,
        note: note,
        note_count: note_count,
        ascents_count: ascents_count,
        sections_count: sections_count,
        likes_count: likes_count&.positive? ? likes_count : nil,
        gym_sector_id: gym_sector_id,
        points: points,
        level_index: level_index,
        level_length: level_length,
        level_color: level_color,
        dismounted: dismounted?,
        points_to_s: points_to_s,
        grade_to_s: grade_to_s,
        thumbnail: thumbnail.attached? ? thumbnail_url : nil,
        gym_route_cover_id: gym_route_cover_id,
        gym_sector_name: gym_sector.name,
        anchor_number: anchor_number,
        short_app_path: short_app_path,
        picture: gym_route_cover ? picture_large_url : nil,
        thumbnail_position: thumbnail_position,
        calculated_thumbnail_position: calculated_thumbnail_position,
        cover_metadata: gym_route_cover&.picture ? gym_route_cover.picture.metadata : nil,
        votes: votes,
        updated_at: updated_at,
        all_comments_count: all_comments_count,
        videos_count: videos_count,
        grade_gap: {
          max_grade_value: max_grade_value,
          min_grade_value: min_grade_value,
          max_grade_text: max_grade_text,
          min_grade_text: min_grade_text
        },
        gym_space: {
          id: gym_space.id,
          slug_name: gym_space.slug_name,
          name: gym_space.name
        },
        gym_sector: {
          id: gym_sector_id,
          name: gym_sector&.name
        },
        gym: {
          id: gym.id,
          slug_name: gym.slug_name
        }
      }
    end
  end

  def detail_to_json
    summary_to_json.merge(
      {
        gym_sector: gym_sector.summary_to_json,
        history: {
          created_at: created_at,
          updated_at: updated_at
        }
      }
    )
  end

  def delete_summary_cache
    Rails.cache.delete("#{cache_key_with_version}/summary_gym_route")
  end

  def refresh_all_comments_count!
    self.all_comments_count = (comments_count || 0) + AscentGymRoute.where(gym_route_id: id).sum(:comments_count)
    save
  end

  private

  def normalize_blank_values
    self.name = nil if name.blank?
  end

  def format_route_section
    new_sections = []
    single_pitch = sections.count == 1

    sections.each do |section|
      section_height = section['height'].present? ? Integer(section['height']) : nil
      grade = Grade.clean_grade(section['grade'])
      new_sections << {
        climbing_type: single_pitch ? climbing_type : section['climbing_type'] || climbing_type,
        description: !single_pitch ? section['description'] : nil,
        grade: grade,
        grade_value: grade.present? ? Grade.to_value(grade) : nil,
        height: single_pitch ? height : section_height,
        points: single_pitch ? points : section['points'],
        styles: section['styles']
      }
    end
    self.sections = new_sections
  end

  def historize_grade_gap
    max_grade_value = nil
    max_grade_text = nil
    min_grade_value = nil
    min_grade_text = nil

    sections.each do |section|
      next unless section['grade']

      max_grade_text = section['grade'] if max_grade_value.nil? || section['grade_value'] > max_grade_value
      max_grade_value = section['grade_value'] if max_grade_value.nil? || section['grade_value'] > max_grade_value

      min_grade_text = section['grade'] if min_grade_value.nil? || section['grade_value'] < min_grade_value
      min_grade_value = section['grade_value'] if min_grade_value.nil? || section['grade_value'] < min_grade_value
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
      errors.add(:grade, I18n.t('activerecord.errors.messages.inclusion')) if section['grade'].present? && !Grade.valid?(section['grade'])

      # Valid numerics
      errors.add(:height, I18n.t('activerecord.errors.messages.greater_than')) if section['height'].present? && Integer(section['height']).negative?
    end
  end

  def historize_level_information
    return unless level_index_changed?

    if level_index
      gym_level = gym.gym_levels.find_by(climbing_type: climbing_type)
      level = gym_level.levels[level_index]
      self.level_length = gym_level.levels.count
      self.level_color = level['color']
    else
      self.level_length = nil
      self.level_color = nil
    end
  end

  def gradiant(colors, fluid: true)
    number_of_color = colors.size
    gradiant = []
    if number_of_color == 1
      gradiant << { color: colors[0], offset: 0 }
      gradiant << { color: colors[0], offset: 100 }
    else
      index = 0
      colors.each do |color|
        if fluid
          gradiant << { color: color, offset: 100 / (number_of_color - 1) * index }
        else
          gradiant << { color: color, offset: 100 / number_of_color * index }
          gradiant << { color: color, offset: 100 / number_of_color * (index + 1) }
          index += 1
        end
      end
    end
    gradiant
  end

  def calculated_thumbnail_position
    return nil unless thumbnail_position

    tp = thumbnail_position.symbolize_keys
    {
      img_h: tp[:img_h].to_d,
      img_w: tp[:img_w].to_d,
      h: tp[:thb_h].to_d / tp[:img_h].to_d * 100,
      w: tp[:thb_w].to_d / tp[:img_w].to_d * 100,
      delta_y: (tp[:img_h].to_d / 2 - tp[:thb_y].to_d) / tp[:img_h].to_d * 100,
      delta_x: (tp[:img_w].to_d / 2 - tp[:thb_x].to_d) / tp[:img_w].to_d * 100
    }
  end

  def delete_contest_route_cache
    contest_routes.each(&:delete_summary_cache)
  end
end
