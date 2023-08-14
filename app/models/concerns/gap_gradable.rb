# frozen_string_literal: true

module GapGradable
  extend ActiveSupport::Concern

  def update_gap!
    gap_gradable = ENV.fetch('GAP_GRADABLE', 'false')
    return if gap_gradable == 'false'

    max_grade = crag_routes.where('crag_routes.max_grade_value > 0').order(max_grade_value: :desc).first
    min_grade = crag_routes.where('crag_routes.min_grade_value > 0').order(min_grade_value: :asc).first

    self.max_grade_value = max_grade&.max_grade_value
    self.max_grade_text = max_grade&.max_grade_text
    self.min_grade_value = min_grade&.min_grade_value
    self.min_grade_text = min_grade&.min_grade_text
    save
  end
end
