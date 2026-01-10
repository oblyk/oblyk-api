class AddSubLevelsToGymLevels < ActiveRecord::Migration[6.0]
  def change
    add_column :gym_levels, :sub_level_enabled, :boolean, default: false
    add_column :gym_levels, :sub_level_max, :integer
    add_column :gym_routes, :sub_level, :integer
    add_column :gym_routes, :sub_level_max, :integer
  end
end
