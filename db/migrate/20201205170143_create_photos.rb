class CreatePhotos < ActiveRecord::Migration[6.0]
  def change
    create_table :photos do |t|
      t.text :description
      t.string :exif_model
      t.string :exif_make
      t.string :source
      t.string :alt

      t.boolean :copyright_by
      t.boolean :copyright_nc
      t.boolean :copyright_nd

      t.references :user
      t.references :illustrable, polymorphic: true

      t.bigint :legacy_id
      t.datetime :posted_at
      t.timestamps
    end
  end
end
