class CreateCragRoutes < ActiveRecord::Migration[6.0]
  def change
    create_table :crag_routes do |t|
      t.string :name
      t.integer :height
      t.integer :open_year
      t.string :opener
      t.json :sections

      # route types
      t.string :climbing_type
      t.string :incline_type
      t.string :reception_type
      t.string :start_type

      # Cache from ascents
      t.integer :difficulty_appreciation
      t.integer :note
      t.integer :note_count
      t.integer :ascents_count

      # Cache from route section
      t.integer :sections_count
      t.integer :max_grade_value
      t.integer :min_grade_value
      t.text :max_grade_text
      t.text :min_grade_text
      t.integer :max_bolt

      t.references :crag
      t.references :crag_sector
      t.references :user

      t.bigint :legacy_id
      t.timestamps
      t.datetime :deleted_at
    end

    add_index :crag_routes, [:name]
  end
end
