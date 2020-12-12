class CreateAscents < ActiveRecord::Migration[6.0]
  def change
    create_table :ascents do |t|
      t.string :type
      t.string :ascent_status
      t.string :roping_status
      t.integer :attempt

      t.references :user
      t.references :crag_route
      t.references :gym_route

      t.json :sections

      # Historization
      t.integer :height
      t.json :hold_colors
      t.json :tag_colors
      t.string :climbing_type

      # Appreciation
      t.string :grade_appreciation_text
      t.integer :grade_appreciation_value
      t.integer :note
      t.text :comment

      # Cache from route section
      t.integer :sections_count
      t.integer :max_grade_value
      t.integer :min_grade_value
      t.text :max_grade_text
      t.text :min_grade_text

      t.string :legacy_hardness_id
      t.bigint :legacy_id

      t.date :released_at
      t.timestamps
    end
  end
end
