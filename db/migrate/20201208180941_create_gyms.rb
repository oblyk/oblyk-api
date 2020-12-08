class CreateGyms < ActiveRecord::Migration[6.0]
  def change
    create_table :gyms do |t|
      t.string :name
      t.text :description

      t.string :address
      t.string :postal_code
      t.string :code_country
      t.string :country
      t.string :city
      t.string :big_city
      t.string :region
      t.string :email
      t.string :phone_number
      t.string :web_site

      t.boolean :bouldering
      t.boolean :sport_climbing
      t.boolean :pan
      t.boolean :fun_climbing
      t.boolean :training_space

      t.decimal :latitude, precision: 10, scale: 6, nil: true
      t.decimal :longitude, precision: 10, scale: 6, nil: true

      t.references :user

      t.string :plan
      t.datetime :plan_start_at
      t.datetime :plan_en_at

      t.datetime :assigned_at

      t.bigint :legacy_id
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :gyms, [:name]
  end
end
