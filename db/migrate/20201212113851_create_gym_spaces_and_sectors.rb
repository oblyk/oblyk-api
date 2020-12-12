class CreateGymSpacesAndSectors < ActiveRecord::Migration[6.0]
  def change
    create_table :gym_spaces do |t|
      t.string :name
      t.text :description
      t.integer :order
      t.string :climbing_type

      t.string :banner_color
      t.string :banner_bg_color
      t.integer :banner_opacity
      t.string :scheme_bg_color
      t.integer :scheme_height
      t.integer :scheme_width

      t.decimal :latitude, precision: 10, scale: 6, nil: true
      t.decimal :longitude, precision: 10, scale: 6, nil: true

      t.references :gym
      t.references :gym_grade

      t.bigint :legacy_id
      t.datetime :deleted_at
      t.datetime :published_at
      t.timestamps
    end

    create_table :gym_sectors do |t|
      t.string :name
      t.text :description
      t.string :group_sector_name
      t.string :climbing_type
      t.integer :height

      t.text :polygon

      t.references :gym_space
      t.references :gym_grade

      t.bigint :legacy_id
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
