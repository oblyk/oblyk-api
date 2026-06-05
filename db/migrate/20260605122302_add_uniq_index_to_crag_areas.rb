class AddUniqIndexToCragAreas < ActiveRecord::Migration[6.0]
  def change
    add_index :area_crags, [:crag_id, :area_id], unique: true
  end
end
