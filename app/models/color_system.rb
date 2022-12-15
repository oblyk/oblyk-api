# frozen_string_literal: true

class ColorSystem < ApplicationRecord
  has_many :color_system_lines

  validates :colors_mark, presence: true, uniqueness: true

  def init_line_form_colors(colors)
    order = 1
    colors.each do |color|
      color_system_line = ColorSystemLine.new(
        hex_color: color,
        order: order
      )
      color_system_lines << color_system_line
      order += 1
    end
  end

  def init_line_form_grade_line(gym_grade)
    gym_grade.gym_grade_lines.each do |gym_grade_line|
      color_system_line = ColorSystemLine.new(
        hex_color: gym_grade_line.colors.first,
        order: gym_grade_line.order
      )
      color_system_lines << color_system_line
    end
  end

  def self.create_form_grade(gym_grade)
    colors_mark = gym_grade.colors_system_mark
    return unless colors_mark

    color_system = ColorSystem.find_or_initialize_by colors_mark: colors_mark
    color_system.init_line_form_grade_line(gym_grade) if color_system.new_record?
    color_system.save
    color_system
  end

  def summary_to_json
    detail_to_json
  end

  def detail_to_json
    {
      id: id,
      colors_mark: colors_mark,
      color_system_lines: color_system_lines.map(&:summary_to_json)
    }
  end
end
