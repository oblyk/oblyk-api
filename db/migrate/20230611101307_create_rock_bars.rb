class CreateRockBars < ActiveRecord::Migration[6.0]
  def change
    create_table :rock_bars do |t|
      t.json :polyline
      t.references :crag
      t.references :crag_sector
      t.timestamps
    end
  end
end
