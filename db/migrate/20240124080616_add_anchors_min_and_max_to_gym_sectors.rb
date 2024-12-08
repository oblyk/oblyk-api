class AddAnchorsMinAndMaxToGymSectors < ActiveRecord::Migration[6.0]
  def change
    add_column :gym_sectors, :min_anchor_number, :integer
    add_column :gym_sectors, :max_anchor_number, :integer
  end
end
