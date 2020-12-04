class CreateGuideBookWebs < ActiveRecord::Migration[6.0]
  def change
    create_table :guide_book_webs do |t|
      t.string :name
      t.string :url
      t.integer :publication_year

      t.references :user
      t.references :crag

      t.bigint :legacy_id
      t.timestamps
    end
  end
end
