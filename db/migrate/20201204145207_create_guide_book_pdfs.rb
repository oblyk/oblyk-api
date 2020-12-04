class CreateGuideBookPdfs < ActiveRecord::Migration[6.0]
  def change
    create_table :guide_book_pdfs do |t|
      t.string :name
      t.text :description
      t.string :author
      t.integer :publication_year

      t.references :crag
      t.references :user

      t.bigint :legacy_id
      t.timestamps
    end
  end
end
