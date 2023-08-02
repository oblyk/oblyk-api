class AddAnchorNumberToGymRoutes < ActiveRecord::Migration[6.0]
  def change
    add_column :gym_routes, :anchor_number, :integer
    add_column :gym_spaces, :anchor, :boolean
  end
end
