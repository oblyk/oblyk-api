class AddElevationToCragsParkAndSectors < ActiveRecord::Migration[6.0]
  def change
    add_column :crags, :elevation, :decimal, precision: 10, scale: 6, nil: true
    add_column :crag_sectors, :elevation, :decimal, precision: 10, scale: 6, nil: true
    add_column :parks, :elevation, :decimal, precision: 10, scale: 6, nil: true
    add_column :approaches, :path_metadata, :json
  end
end
