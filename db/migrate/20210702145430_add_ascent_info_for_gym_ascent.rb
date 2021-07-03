class AddAscentInfoForGymAscent < ActiveRecord::Migration[6.0]
  def change
    add_column :gym_grades, :deleted_at, :datetime

    add_column :ascents, :gym_grade_level, :integer
    add_reference :ascents, :gym
    add_reference :ascents, :gym_grade

    remove_column :ascents, :hold_colors
    remove_column :ascents, :tag_colors
  end
end
