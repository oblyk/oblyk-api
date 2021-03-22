class CreateArticlesTables < ActiveRecord::Migration[6.0]
  def change
    create_table :authors do |t|
      t.string :name
      t.text :description
      t.references :user
      t.timestamps
    end

    create_table :articles do |t|
      t.string :name
      t.string :slug_name
      t.text :description
      t.text :body
      t.integer :views
      t.references :author

      t.datetime :published_at
      t.timestamps
    end

    create_table :article_crags do |t|
      t.references :article
      t.references :crag
      t.timestamps
    end

    create_table :article_guide_book_papers do |t|
      t.references :article
      t.references :guide_book_paper
      t.timestamps
    end

    add_column :crags, :articles_count, :integer
    add_column :guide_book_papers, :articles_count, :integer

    add_index :article_crags, %i(crag_id article_id), unique: true, name: :unique_crag_and_article_index
    add_index :article_guide_book_papers, %i(guide_book_paper_id article_id), unique: true, name: :unique_guide_book_and_article_index
  end
end
