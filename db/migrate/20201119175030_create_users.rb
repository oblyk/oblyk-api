class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :first_name, null: false
      t.string :last_name
      t.string :email, null: false
      t.string :password_digest, null: false
      t.date :date_of_birth
      t.string :genre
      t.text :description

      # Options
      t.boolean :public, default: false
      t.boolean :partner_search, default: false
      t.datetime :newsletter_accepted_at

      # partner search parameters
      t.decimal :latitude, precision: 10, scale: 6, nil: true
      t.decimal :longitude, precision: 10, scale: 6, nil: true
      t.boolean :bouldering, default: false
      t.boolean :sport_climbing, default: false
      t.boolean :multi_pitch, default: false
      t.boolean :trad_climbing, default: false
      t.boolean :aid_climbing, default: false
      t.boolean :deep_water, default: false
      t.boolean :via_ferrata, default: false
      t.boolean :pan, default: false
      t.string :grade_max
      t.string :grade_min

      t.boolean :super_admin, default: false

      t.bigint :legacy_id
      t.timestamps
      t.datetime :deleted_at
    end

    add_index :users, [:email], unique: true
  end
end
