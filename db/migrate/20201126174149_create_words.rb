class CreateWords < ActiveRecord::Migration[6.0]
  def change
    create_table :words do |t|
      t.string :name
      t.text :definition

      t.references :user

      t.bigint :legacy_id
      t.timestamps
    end

    add_index :words, [:name], unique: true
  end
end
