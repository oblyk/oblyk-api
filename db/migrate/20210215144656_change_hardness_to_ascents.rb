class ChangeHardnessToAscents < ActiveRecord::Migration[6.0]
  def change
    add_column :ascents, :hardness_status, :string
    remove_column :ascents, :grade_appreciation_text
    remove_column :ascents, :grade_appreciation_value
    remove_column :ascents, :legacy_hardness_id
    change_column :crag_routes, :difficulty_appreciation, :float, precision: 6, scale: 2
  end
end
