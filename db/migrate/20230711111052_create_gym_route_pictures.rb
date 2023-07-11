class CreateGymRoutePictures < ActiveRecord::Migration[6.0]
  def change
    create_table :gym_route_covers do |t|
      t.timestamps
    end
    remove_column :gym_routes, :duplicate_picture
    add_reference :gym_routes, :gym_route_cover, after: :gym_sector_id
  end
end
