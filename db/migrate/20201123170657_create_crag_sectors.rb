class CreateCragSectors < ActiveRecord::Migration[6.0]
  def change
    create_table :crag_sectors do |t|
      t.string :name
      t.text :description

      t.string :rain
      t.string :sun

      # localisation
      t.decimal :latitude, precision: 10, scale: 6, nil: true
      t.decimal :longitude, precision: 10, scale: 6, nil: true

      # orientation
      t.boolean :north
      t.boolean :north_east
      t.boolean :east
      t.boolean :south_east
      t.boolean :south
      t.boolean :south_west
      t.boolean :west
      t.boolean :north_west

      t.references :user
      t.references :crag

      # Cache columns
      t.integer :crag_routes_count
      t.integer :min_grade_value
      t.integer :max_grade_value
      t.string :max_grade_text
      t.string :min_grade_text

      t.bigint :legacy_id
      t.timestamps
      t.datetime :deleted_at
    end

    add_index :crag_sectors, [:name]
  end
end
