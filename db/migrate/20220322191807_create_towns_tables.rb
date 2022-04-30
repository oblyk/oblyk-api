class CreateTownsTables < ActiveRecord::Migration[6.0]
  def change
    create_table :countries do |t|
      t.string :name
      t.string :slug_name
      t.string :code_country, limit: 5
      t.json :geo_polygon
      t.timestamps
    end
    add_index :countries, :name
    add_index :countries, [:slug_name], unique: true

    create_table :departments do |t|
      t.string :name
      t.string :slug_name
      t.string :department_number, limit: 5
      t.string :name_prefix_type
      t.string :in_sentence_prefix_type
      t.json :geo_polygon
      t.references :country
      t.timestamps
    end
    add_index :departments, :name
    add_index :departments, :department_number
    add_index :departments, [:slug_name], unique: true

    create_table :towns do |t|
      t.string :name
      t.string :slug_name
      t.decimal :latitude, precision: 10, scale: 6, nil: true
      t.decimal :longitude, precision: 10, scale: 6, nil: true
      t.integer :population
      t.string :town_code, limit: 5
      t.string :zipcode, limit: 5
      t.references :department
      t.timestamps
    end

    add_index :towns, :name
    add_index :towns, :latitude
    add_index :towns, :longitude
    add_index :towns, [:slug_name], unique: true

    add_reference :crags, :department
    add_reference :gyms, :department
  end
end
