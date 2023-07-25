class AddDifficultyAppreciationToGymRoutes < ActiveRecord::Migration[6.0]
  def change
    remove_column :gym_routes, :grade_value_appreciation
    add_column :gym_routes, :difficulty_appreciation, :float
    add_column :gym_routes, :votes, :json
  end
end
