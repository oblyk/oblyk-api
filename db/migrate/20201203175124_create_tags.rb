class CreateTags < ActiveRecord::Migration[6.0]
  def change
    create_table :tags do |t|
      t.string :name

      t.references :taggable, polymorphic: true
      t.references :user

      t.bigint :legacy_id
      t.timestamps
    end
  end
end
