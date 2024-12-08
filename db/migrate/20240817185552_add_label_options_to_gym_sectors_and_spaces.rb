class AddLabelOptionsToGymSectorsAndSpaces < ActiveRecord::Migration[6.0]
  def change
    add_column :gym_spaces, :three_d_label_options, :json, after: :three_d_camera_position
    add_column :gym_sectors, :three_d_label_options, :json
  end
end
