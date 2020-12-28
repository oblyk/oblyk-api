class AddHasSeveralPitchToGymSectors < ActiveRecord::Migration[6.0]
  def change
    add_column :gym_sectors, :can_be_more_than_one_pitch, :boolean, default: :false
  end
end
