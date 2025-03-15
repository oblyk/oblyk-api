class AddThreeDElevatedToGymSectors < ActiveRecord::Migration[6.0]
  def change
    add_column :gym_sectors, :three_d_elevated, :decimal, precision: 10, scale: 6, default: 0.0, after: :three_d_height
  end
end
