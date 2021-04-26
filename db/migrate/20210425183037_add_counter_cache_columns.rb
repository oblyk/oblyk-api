class AddCounterCacheColumns < ActiveRecord::Migration[6.0]
  def change
    add_column :articles, :photos_count, :integer
    add_column :gyms, :videos_count, :integer
  end
end
