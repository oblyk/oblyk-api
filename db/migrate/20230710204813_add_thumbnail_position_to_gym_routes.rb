class AddThumbnailPositionToGymRoutes < ActiveRecord::Migration[6.0]
  def change
    add_column :gym_routes, :thumbnail_position, :json
  end
end
