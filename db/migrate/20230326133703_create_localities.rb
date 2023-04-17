class CreateLocalities < ActiveRecord::Migration[6.0]
  def change
    create_table :localities do |t|
      t.string :name
      t.string :code_country
      t.string :region
      t.integer :partner_search_users_count
      t.integer :local_sharing_users_count
      t.integer :distinct_users_count
      t.decimal :latitude, precision: 10, scale: 6, nil: true
      t.decimal :longitude, precision: 10, scale: 6, nil: true
      t.timestamps
    end

    add_index :localities, :latitude
    add_index :localities, :longitude

    create_table :locality_users do |t|
      t.references :user
      t.references :locality
      t.boolean :partner_search
      t.boolean :local_sharing
      t.text :description
      t.integer :radius
      t.datetime :deactivated_at
      t.timestamps
    end

    add_column :users, :last_partner_check_at, :datetime, after: :partner_search_activated_at
    add_column :users, :partner_notified_at, :datetime, after: :last_partner_check_at
  end
end
