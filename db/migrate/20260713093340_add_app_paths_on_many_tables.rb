class AddAppPathsOnManyTables < ActiveRecord::Migration[6.1]
  def change
    add_column :gyms, :app_paths, :json
    add_column :gyms, :public_guide_book, :boolean, default: false
  end
end
