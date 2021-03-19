class CreateFeeds < ActiveRecord::Migration[6.0]
  def change
    create_table :feeds do |t|
      t.references :feedable, polymorphic: true
      t.json :feed_object
      t.string :parent_type
      t.bigint :parent_id
      t.json :parent_object

      # localisation
      t.decimal :latitude, precision: 10, scale: 6, nil: true
      t.decimal :longitude, precision: 10, scale: 6, nil: true

      t.datetime :posted_at
      t.timestamps
    end

    add_index :feeds, :posted_at
    add_index :feeds, :parent_type
    add_index :feeds, :parent_id
    add_index :feeds, :latitude
    add_index :feeds, :longitude
  end
end
