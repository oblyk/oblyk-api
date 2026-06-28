class AddIndexOnSomeCreatedAt < ActiveRecord::Migration[6.0]
  def change
    add_index :crags, :created_at
    add_index :users, :created_at
    add_index :gyms, :created_at
    add_index :gym_routes, :created_at
    add_index :crag_routes, :created_at
    add_index :ascents, :created_at
    add_index :ascents, :released_at
    add_index :photos, :created_at
    add_index :guide_book_papers, :created_at
    add_index :guide_book_pdfs, :created_at
    add_index :guide_book_webs, :created_at
    add_index :comments, :created_at
    add_index :videos, :created_at
  end
end
