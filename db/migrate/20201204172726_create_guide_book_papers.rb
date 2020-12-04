class CreateGuideBookPapers < ActiveRecord::Migration[6.0]
  def change
    create_table :guide_book_papers do |t|
      t.string :name
      t.string :author
      t.string :editor
      t.integer :publication_year
      t.integer :price_cents
      t.string :ean
      t.string :vc_reference
      t.integer :number_of_page
      t.integer :weight

      t.references :user

      t.bigint :legacy_id
      t.timestamps
    end

    create_table :guide_book_paper_crags do |t|
      t.references :crag
      t.references :guide_book_paper
      t.references :user

      t.timestamps
    end

    add_index :guide_book_paper_crags, [:crag_id, :guide_book_paper_id], unique: true
  end
end
