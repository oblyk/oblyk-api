class AddDuplicatePictureToGymRoutes < ActiveRecord::Migration[6.0]
  def change
    add_column :gym_routes, :duplicate_picture, :boolean
  end
end
