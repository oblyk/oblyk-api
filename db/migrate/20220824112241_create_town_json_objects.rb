class CreateTownJsonObjects < ActiveRecord::Migration[6.0]
  def change
    create_table :town_json_objects do |t|
      t.integer :dist
      t.references :town
      t.json :json_object
      t.datetime :version_date
      t.timestamps
    end

    add_index :town_json_objects, :dist
  end
end
