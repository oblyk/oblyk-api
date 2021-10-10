# frozen_string_literal: true

class AscentGymRoute < Ascent
  belongs_to :gym_route, optional: true
  belongs_to :gym
  belongs_to :gym_grade, optional: true

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
    {
      id: id,
      ascent_status: ascent_status,
      hardness_status: hardness_status,
      gym_route_id: gym_route_id,
      gym_grade_id: gym_grade_id,
      gym_grade_level: gym_grade_level,
      sections: sections,
      height: height,
      note: note,
      comment: comment,
      sections_count: sections_count,
      max_grade_value: max_grade_value,
      min_grade_value: min_grade_value,
      max_grade_text: max_grade_text,
      min_grade_text: min_grade_text,
      released_at: released_at,
      private_comment: private_comment,
      sections_done: sections_done,
      gym_route: gym_route ? gym_route.summary_to_json : nil,
      gym: {
        id: gym.id,
        name: gym.name,
        slug_name: gym.slug_name
      },
      history: {
        created_at: created_at,
        updated_at: updated_at
      },
      user: {
        uuid: user.uuid,
        first_name: user.first_name,
        last_name: user.last_name,
        slug_name: user.slug_name
      }
    }
  end

  private

  def update_gym_route!
    return unless gym_route

    gym_route.update_form_ascents!
  end

  def set_gym_and_system
    return unless gym_route

    self.gym = gym_route.gym
    self.gym_grade = gym_route.gym_grade_line.gym_grade if gym_route.gym_grade_line
    self.gym_grade_level = gym_route.gym_grade_line.order if gym_route.gym_grade_line
  end

  def historize_ascents
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
    self.sections_count = sections.count
  end
end
