class AddPhotoToCragSectorAndRoute < ActiveRecord::Migration[6.0]
  def change
    add_reference :crags, :photo
    add_reference :crag_sectors, :photo
    add_reference :crag_routes, :photo
  end
end
