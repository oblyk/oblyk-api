class AddDescriptionToGymRoute < ActiveRecord::Migration[6.0]
  def change
    add_column :gym_routes, :description, :text
  end
end
