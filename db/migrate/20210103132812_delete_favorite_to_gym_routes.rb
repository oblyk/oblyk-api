class DeleteFavoriteToGymRoutes < ActiveRecord::Migration[6.0]
  def change
    remove_column :gym_routes, :favorite
  end
end
