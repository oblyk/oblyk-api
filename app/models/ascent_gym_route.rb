# frozen_string_literal: true

class AscentGymRoute < Ascent
  belongs_to :gym_route, optional: true
  belongs_to :gym
  belongs_to :gym_grade, optional: true # TODO : DELETE AFTER MIGRATION
  belongs_to :color_system_line, optional: true
  has_one :ascent_comment, class_name: 'Comment', as: :commentable, dependent: :destroy

  validates :climbing_type, inclusion: { in: Climb::GYM_LIST }

  before_validation :set_gym_and_system
  before_validation :historize_ascents
  before_validation :historize_grade_gap

  after_save :update_gym_route!
  after_destroy :update_gym_route!

  def summary_to_json
    detail_to_json
  end

  def detail_to_json
    public_comment = nil
    if ascent_comment
      public_comment = {
        id: ascent_comment.id,
        body: ascent_comment.body
      }
    end
    {
      id: id,
      ascent_status: ascent_status,
      roping_status: roping_status,
      hardness_status: hardness_status,
      gym_route_id: gym_route_id,
      gym_grade_level: gym_grade_level,
      sections: sections,
      height: height,
      note: note,
      comment: comment,
      ascent_comment: public_comment,
      quantity: quantity,
      sections_count: sections_count,
      max_grade_value: max_grade_value,
      min_grade_value: min_grade_value,
      max_grade_text: max_grade_text,
      min_grade_text: min_grade_text,
      released_at: released_at,
      private_comment: private_comment,
      sections_done: sections_done,
      gym_route: gym_route ? gym_route.summary_to_json : nil,
      gym: gym.summary_to_json,
      climbing_type: climbing_type,
      points: points,
      history: {
        created_at: created_at,
        updated_at: updated_at
      },
      color_system_line: color_system_line&.summary_to_json,
      color_system: color_system_line&.color_system&.summary_to_json,
      user: user.summary_to_json(with_avatar: false)
    }
  end

  def commentary_public!
    return if comment.blank?
    return if ascent_comment.present?

    self.ascent_comment = Comment.new(
      body: comment,
      user: user,
      created_at: created_at,
      updated_at: updated_at
    )
    update_column :comment, nil
    gym_route.delete_summary_cache
  end

  def init_level_color
    return unless gym_route

    gym_level = gym_route.gym.gym_levels.find_by climbing_type: gym_route.climbing_type
    return unless gym_level&.levels&.count&.positive?

    color_system = ColorSystem.create_from_level gym_level
    self.color_system_line = color_system.color_system_lines.find_by(hex_color: gym_route.level_color) if color_system
  end

  def points(gym_route = nil, gym = nil)
    gym_route ||= self.gym_route
    gym ||= self.gym
    base = gym_route.calculated_point
    status_multiplier = gym.ascents_multiplier[gym_route.climbing_type][ascent_status] || 1
    roping_multiplier = gym.ascents_multiplier[gym_route.climbing_type][roping_status] || 1
    multiplier = status_multiplier * roping_multiplier
    {
      base: base,
      multiplier: multiplier,
      status_multiplier: status_multiplier,
      roping_multiplier: roping_multiplier,
      score: (base * multiplier).round
    }
  end

  private

  def update_gym_route!
    return unless gym_route

    gym_route.update_form_ascents!
    gym_route.refresh_all_comments_count! if comments_count&.positive?
  end

  def set_gym_and_system
    return unless gym_route

    self.gym = gym_route.gym
    self.gym_grade_level = gym_route.level_index
  end

  def historize_ascents
    return unless gym_route
    return if selected_sections.blank?

    self.height = gym_route.height
    self.climbing_type = gym_route.climbing_type

    # Sections
    sections = []
    gym_route.sections.each_with_index do |section, index|
      next unless selected_sections.include? index

      sections << {
        index: index,
        height: section['height'],
        grade: section['grade'],
        grade_value: section['grade_value']
      }
    end
    self.sections = sections
  end

  def historize_grade_gap
    max_grade_value = nil
    max_grade_text = nil
    min_grade_value = nil
    min_grade_text = nil

    sections.each do |section|
      next unless section['grade_value']

      max_grade_text = section['grade'] if max_grade_value.blank? || section['grade_value'] > max_grade_value
      max_grade_value = section['grade_value'] if max_grade_value.blank? || section['grade_value'] > max_grade_value

      min_grade_text = section['grade'] if min_grade_value.blank? || section['grade_value'] < min_grade_value
      min_grade_value = section['grade_value'] if min_grade_value.blank? || section['grade_value'] < min_grade_value
    end

    self.max_grade_text = max_grade_text
    self.min_grade_text = min_grade_text
    self.max_grade_value = max_grade_value
    self.min_grade_value = min_grade_value
    self.sections_count = sections.count
  end
end
