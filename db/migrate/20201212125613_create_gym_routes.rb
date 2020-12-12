class CreateGymRoutes < ActiveRecord::Migration[6.0]
  def change
    create_table :gym_routes do |t|
      t.string :name
      t.integer :height
      t.string :climbing_type
      t.boolean :favorite
      t.string :openers
      t.text :polyline

      t.json :hold_colors
      t.json :tag_colors

      t.json :sections

      t.references :gym_sector
      t.references :gym_grade_line

      # Cache from ascents
      t.integer :grade_value_appreciation
      t.integer :note
      t.integer :note_count
      t.integer :ascents_count

      # Cache from route section
      t.integer :sections_count
      t.integer :max_grade_value
      t.integer :min_grade_value
      t.text :max_grade_text
      t.text :min_grade_text

      t.bigint :legacy_id
      t.datetime :archived_at
      t.date :opened_at
      t.datetime :dismounted_at
      t.timestamps
    end
  end
end
