class AddLocationToRouteAndSector < ActiveRecord::Migration[6.0]
  def change
    add_column :crag_routes, :location, :json
    add_column :crag_sectors, :location, :json
  end
end
