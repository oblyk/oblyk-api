class AddDimensionToPhoto < ActiveRecord::Migration[6.0]
  def change
    add_column :photos, :photo_height, :integer
    add_column :photos, :photo_width, :integer
  end
end
