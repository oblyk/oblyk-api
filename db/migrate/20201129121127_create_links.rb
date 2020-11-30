class CreateLinks < ActiveRecord::Migration[6.0]
  def change
    create_table :links do |t|
      t.string :name
      t.string :url
      t.text :description

      t.references :linkable, polymorphic: true
      t.references :user

      t.bigint :legacy_id
      t.timestamps
    end
  end
end
