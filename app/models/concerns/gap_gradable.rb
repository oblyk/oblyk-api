# frozen_string_literal: true

module GapGradable
  extend ActiveSupport::Concern

  def update_gap!
    max_grade = crag_routes.order(max_grade_value: :desc).first
    min_grade = crag_routes.order(min_grade_value: :asc).first

    self.max_grade_value = max_grade&.max_grade_value
    self.max_grade_text = max_grade&.max_grade_text
    self.min_grade_value = min_grade&.min_grade_value
    self.min_grade_text = min_grade&.min_grade_text
    save
  end
end
