# frozen_string_literal: true

class ClimbingSession < ApplicationRecord
  belongs_to :user

  has_many :ascents
  has_many :ascent_gym_routes
  has_many :ascent_crag_routes

  def summary_to_json
    crag_ascents = ascents.select { |ascent| ascent.type == 'AscentCragRoute' }.sort_by { |ascent| -(ascent.max_grade_value || 0) }
    gym_ascents = ascents.made.select { |ascent| ascent.type == 'AscentGymRoute' }.sort_by { |ascent| -(ascent.max_grade_value || 0) }

    crag_ids = []
    gym_ids = []

    by_colors = {}
    by_grade = {}
    project_by_grade = {}

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

      if crag_ascent.ascent_status == 'project'
        project_by_grade[crag_ascent.max_grade_text] ||= {
          grade_text: crag_ascent.max_grade_text,
          grade_value: crag_ascent.max_grade_value,
          count: 0
        }
        project_by_grade[crag_ascent.max_grade_text][:count] += 1
      else
        by_grade[crag_ascent.max_grade_text] ||= {
          grade_text: crag_ascent.max_grade_text,
          grade_value: crag_ascent.max_grade_value,
          count: 0
        }
        by_grade[crag_ascent.max_grade_text][:count] += 1
      end
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
        by_colors: by_colors.map { |color| color[1] },
        project_by_grades: project_by_grade.map { |grade| grade[1] },
      },
      user: {
        uuid: user.uuid,
        first_name: user.first_name,
        last_name: user.last_name,
        slug_name: user.slug_name
      }
    }
  end

  def detail_to_json
    previous_climbing_session = ClimbingSession
                                .where(user: user)
                                .where('climbing_sessions.session_date < ?', session_date)
                                .maximum(:session_date)
    next_climbing_session = ClimbingSession
                            .where(user: user)
                            .where('climbing_sessions.session_date > ?', session_date)
                            .minimum(:session_date)

    user_ids = AscentUser.where(ascent_id: ascent_crag_routes.pluck(:id)).pluck(:user_id).uniq

    summary = summary_to_json
    summary[:crags] = Crag.where(id: summary[:crags]).map(&:summary_to_json)
    summary[:gyms] = Gym.where(id: summary[:gyms]).map(&:summary_to_json)
    summary[:gym_ascents] = ascent_gym_routes.map(&:summary_to_json)
    summary[:crag_ascents] = []
    ascent_crag_routes.each do |ascent_crag_route|
      ascent_route = ascent_crag_route.summary_to_json
      ascent_route[:crag_route][:grade_gap][:max_grade_value] = ascent_crag_route.max_grade_value
      ascent_route[:crag_route][:grade_gap][:min_grade_value] = ascent_crag_route.min_grade_value
      ascent_route[:crag_route][:grade_gap][:max_grade_text] = ascent_crag_route.max_grade_text
      ascent_route[:crag_route][:grade_gap][:min_grade_text] = ascent_crag_route.min_grade_text
      summary[:crag_ascents] << ascent_route
    end
    summary[:previous_climbing_session] = previous_climbing_session
    summary[:next_climbing_session] = next_climbing_session
    summary[:users] = User.where(id: user_ids).map(&:summary_to_json)
    summary
  end

  def remove_if_empty!
    return if description.present?
    return if ascents.count.positive?

    destroy
  end
end
