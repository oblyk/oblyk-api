class AddPointSystemToGym < ActiveRecord::Migration[6.0]
  def change
    add_column :gym_grades, :use_grade_system, :boolean, default: false
    add_column :gym_grades, :use_point_system, :boolean, default: false

    add_column :gym_grade_lines, :points, :integer

    add_column :gym_routes, :points, :integer

    add_column :ascents, :points, :integer
  end
end
