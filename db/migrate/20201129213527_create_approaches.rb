class CreateApproaches < ActiveRecord::Migration[6.0]
  def change
    create_table :approaches do |t|
      t.text :polyline
      t.text :description
      t.integer :length
      t.string :approach_type

      t.references :crag
      t.references :user

      t.bigint :legacy_id
      t.timestamps
    end
  end
end
