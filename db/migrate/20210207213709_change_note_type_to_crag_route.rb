class ChangeNoteTypeToCragRoute < ActiveRecord::Migration[6.0]
  def change
    change_column :crag_routes, :note, :float, precision: 6, scale: 2
  end
end
