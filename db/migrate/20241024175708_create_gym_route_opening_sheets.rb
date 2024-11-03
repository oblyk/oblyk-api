class CreateGymRouteOpeningSheets < ActiveRecord::Migration[6.0]
  def change
    create_table :gym_opening_sheets do |t|
      t.string :title
      t.text :description
      t.json :row_json
      t.integer :number_of_columns
      t.datetime :archived_at
      t.references :gym, foreign_key: true
      t.timestamps
    end
  end
end
