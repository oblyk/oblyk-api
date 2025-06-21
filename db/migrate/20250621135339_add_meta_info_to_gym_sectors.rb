class AddMetaInfoToGymSectors < ActiveRecord::Migration[6.0]
  def change
    add_column :gym_sectors, :linear_metre, :float, precision: 6, scale: 2
    add_column :gym_sectors, :developed_metre, :float, precision: 6, scale: 2
    add_column :gym_sectors, :category_name, :string
    add_column :gym_sectors, :average_opening_time, :integer
  end
end
