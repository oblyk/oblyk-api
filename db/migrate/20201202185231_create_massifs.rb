class CreateMassifs < ActiveRecord::Migration[6.0]
  def change
    create_table :areas do |t|
      t.string :name

      t.references :user

      t.bigint :legacy_id
      t.timestamps
    end

    create_table :area_crags do |t|
      t.references :crag
      t.references :area
      t.references :user

      t.timestamps
    end
  end
end
