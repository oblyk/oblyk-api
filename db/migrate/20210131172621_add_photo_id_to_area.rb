class AddPhotoIdToArea < ActiveRecord::Migration[6.0]
  def change
    add_reference :areas, :photo
  end
end
