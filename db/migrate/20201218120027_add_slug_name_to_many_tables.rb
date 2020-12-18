class AddSlugNameToManyTables < ActiveRecord::Migration[6.0]
  def change
    add_column :areas, :slug_name, :string
    add_column :crag_routes, :slug_name, :string
    add_column :crag_sectors, :slug_name, :string
    add_column :crags, :slug_name, :string
    add_column :guide_book_papers, :slug_name, :string
    add_column :gym_spaces, :slug_name, :string
    add_column :gyms, :slug_name, :string
    add_column :words, :slug_name, :string
  end
end
