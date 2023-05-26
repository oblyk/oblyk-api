class AddSectorsColorToGymSpaces < ActiveRecord::Migration[6.0]
  def change
    remove_column :gym_spaces, :banner_color
    remove_column :gym_spaces, :banner_bg_color
    remove_column :gym_spaces, :banner_opacity
    remove_column :gym_spaces, :scheme_bg_color

    add_column :gym_spaces, :sectors_color, :string, after: :scheme_width
  end
end
