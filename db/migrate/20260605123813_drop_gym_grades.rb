class DropGymGrades < ActiveRecord::Migration[6.0]
  def change
    remove_column :ascents, :gym_grade_id
    remove_column :gym_spaces, :gym_grade_id
    remove_column :gym_sectors, :gym_grade_id
    remove_column :gym_routes, :gym_grade_line_id
    drop_table :gym_grade_lines
    drop_table :gym_grades
  end
end
