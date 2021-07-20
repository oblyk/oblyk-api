class CreateSearches < ActiveRecord::Migration[6.0]
  def change
    create_table :searches do |t|
      t.string :index_name
      t.bigint :index_id
      t.string :collection
      t.string :bucket
      t.string :secondary_bucket
    end

    add_index :searches, :index_id
    add_index :searches, :index_name
    add_index :searches, :collection
    add_index :searches, :bucket
    add_index :searches, :secondary_bucket
  end
end
