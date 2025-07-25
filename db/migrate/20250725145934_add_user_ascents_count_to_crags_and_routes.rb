class AddUserAscentsCountToCragsAndRoutes < ActiveRecord::Migration[6.0]
  def change
    add_column :crags, :ascent_users_count, :integer, default: 0, index: true
    add_column :crags, :ascents_count, :integer, default: 0
    add_column :crag_sectors, :ascent_users_count, :integer, default: 0, index: true
    add_column :crag_sectors, :ascents_count, :integer, default: 0
    add_column :crag_routes, :ascent_users_count, :integer, default: 0, after: :ascents_count, index: true
  end
end
