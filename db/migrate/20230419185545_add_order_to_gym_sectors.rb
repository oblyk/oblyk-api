class AddOrderToGymSectors < ActiveRecord::Migration[6.0]
  def change
    add_column :gym_sectors, :order, :integer, default: 0
  end
end
