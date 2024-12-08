class CreateGymLevels < ActiveRecord::Migration[6.0]
  def change
    create_table :gym_levels do |t|
      t.references :gym, foreign_key: true
      t.string :climbing_type
      t.string :grade_system
      t.string :level_representation
      t.json :levels
    end

    add_index :gym_levels, [:gym_id, :climbing_type], unique: true

    add_column :gym_routes, :level_index, :integer, after: :min_grade_text
    add_column :gym_routes, :level_length, :integer, after: :level_index
    add_column :gym_routes, :level_color, :string, after: :level_length
  end
end
