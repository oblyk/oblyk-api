class AddUsePointDivisionSystemToGymGrade < ActiveRecord::Migration[6.0]
  def change
    add_column :gym_grades, :use_point_division_system, :boolean, default: false
  end
end
