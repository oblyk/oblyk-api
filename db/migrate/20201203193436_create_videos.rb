class CreateVideos < ActiveRecord::Migration[6.0]
  def change
    create_table :videos do |t|
      t.text :description
      t.string :url

      t.references :user
      t.references :viewable, polymorphic: true

      t.bigint :legacy_id
      t.timestamps
    end
  end
end
