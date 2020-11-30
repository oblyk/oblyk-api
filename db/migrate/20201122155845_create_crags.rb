class CreateCrags < ActiveRecord::Migration[6.0]
  def change
    create_table :crags do |t|
      t.string :name

      # crags description
      t.json :rocks
      t.string :rain
      t.string :sun

      # localisation
      t.decimal :latitude, precision: 10, scale: 6, nil: true
      t.decimal :longitude, precision: 10, scale: 6, nil: true
      t.string :code_country
      t.string :country
      t.string :city
      t.string :region

      # climbing type
      t.boolean :sport_climbing, default: false
      t.boolean :bouldering, default: false
      t.boolean :multi_pitch, default: false
      t.boolean :trad_climbing, default: false
      t.boolean :aid_climbing, default: false
      t.boolean :deep_water, default: false
      t.boolean :via_ferrata, default: false

      # Season
      t.boolean :summer
      t.boolean :autumn
      t.boolean :winter
      t.boolean :spring

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

    add_index :crags, [:name]
  end
end
