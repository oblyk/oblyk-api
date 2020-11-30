class CreateParks < ActiveRecord::Migration[6.0]
  def change
    create_table :parks do |t|
      t.text :description

      # localisation
      t.decimal :latitude, precision: 10, scale: 6, nil: true
      t.decimal :longitude, precision: 10, scale: 6, nil: true

      t.references :crag
      t.references :user

      t.bigint :legacy_id
      t.timestamps
    end
  end
end
