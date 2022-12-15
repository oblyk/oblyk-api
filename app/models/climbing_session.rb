# frozen_string_literal: true

class ClimbingSession < ApplicationRecord
  belongs_to :user

  has_many :ascents
  has_many :ascent_gym_routes
  has_many :ascent_crag_routes

  def summary_to_json
    crag_ascents = ascents.select { |ascent| ascent.type == 'AscentCragRoute' }.sort_by { |ascent| -(ascent.max_grade_value || 0) }
    gym_ascents = ascents.select { |ascent| ascent.type == 'AscentGymRoute' }.sort_by { |ascent| -(ascent.max_grade_value || 0) }

    crag_ids = []
    gym_ids = []

    by_colors = {}
    by_grade = {}
    gym_ascents.each do |gym_ascent|
      gym_ids << gym_ascent.gym_id unless gym_ids.include? gym_ascent.gym_id

      if gym_ascent.color_system_line
        by_colors[gym_ascent.color_system_line.hex_color] ||= {
          color: gym_ascent.color_system_line.hex_color,
          count: 0
        }
        by_colors[gym_ascent.color_system_line.hex_color][:count] += gym_ascent.quantity
      end

      next unless gym_ascent.max_grade_value

      by_grade[gym_ascent.max_grade_text] ||= {
        grade_text: gym_ascent.max_grade_text,
        grade_value: gym_ascent.max_grade_value,
        count: 0
      }
      by_grade[gym_ascent.max_grade_text][:count] += gym_ascent.quantity
    end

    crag_ascents.each do |crag_ascent|
      crag_ids << crag_ascent.crag_route.crag_id unless crag_ids.include? crag_ascent.crag_route.crag_id

      by_grade[crag_ascent.max_grade_text] ||= {
        grade_text: crag_ascent.max_grade_text,
        grade_value: crag_ascent.max_grade_value,
        count: 0
      }
      by_grade[crag_ascent.max_grade_text][:count] += 1
    end

    {
      id: id,
      description: description,
      user_id: user_id,
      session_date: session_date,
      crags: crag_ids,
      gyms: gym_ids,
      stats: {
        count: ascents.size,
        by_grades: by_grade.map { |grade| grade[1] },
        by_colors: by_colors.map { |color| color[1] }
      }
    }
  end

  def detail_to_json
    summary = summary_to_json
    summary[:crags] = Crag.where(id: summary[:crags]).map(&:summary_to_json)
    summary[:gyms] = Gym.where(id: summary[:gyms]).map(&:summary_to_json)
    summary[:gym_ascents] = ascent_gym_routes.map(&:summary_to_json)
    summary[:crag_ascents] = ascent_crag_routes.map(&:summary_to_json)
    summary
  end

  def remove_if_empty!
    return if description.present?
    return if ascents.count.positive?

    destroy
  end
end
