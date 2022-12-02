class RefactorGradeSystem < ActiveRecord::Migration[6.0]
  def change
    remove_column :gym_grades, :difficulty_system
    remove_column :gym_grades, :has_hold_color
    remove_column :gym_grades, :legacy_id
    remove_column :gym_grades, :use_point_system
    remove_column :gym_grades, :use_point_division_system

    rename_column :gym_grades, :use_grade_system, :difficulty_by_grade

    add_column :gym_grades, :difficulty_by_level, :boolean
    add_column :gym_grades, :tag_color, :boolean
    add_column :gym_grades, :hold_color, :boolean
    add_column :gym_grades, :point_system_type, :string, default: 'none'

    change_column :gym_grades, :deleted_at, :datetime, after: :updated_at
  end
end
