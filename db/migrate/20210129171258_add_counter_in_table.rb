class AddCounterInTable < ActiveRecord::Migration[6.0]
  def change

    # Comments count
    add_column :crag_routes, :comments_count, :integer
    add_column :crag_sectors, :comments_count, :integer
    add_column :crags, :comments_count, :integer
    add_column :areas, :comments_count, :integer
    add_column :gym_routes, :comments_count, :integer

    # Videos count
    add_column :crags, :videos_count, :integer
    add_column :crag_routes, :videos_count, :integer
    add_column :gym_routes, :videos_count, :integer

    # Photos counts
    add_column :crags, :photos_count, :integer
    add_column :crag_routes, :photos_count, :integer
    add_column :crag_sectors, :photos_count, :integer

    # Follows counts
    add_column :crags, :follows_count, :integer
    add_column :users, :follows_count, :integer
    add_column :guide_book_papers, :follows_count, :integer
    add_column :gyms, :follows_count, :integer
  end
end
