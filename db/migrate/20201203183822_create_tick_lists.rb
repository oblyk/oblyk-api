class CreateTickLists < ActiveRecord::Migration[6.0]
  def change
    create_table :tick_lists do |t|
      t.references :user
      t.references :crag_route

      t.timestamps
    end
  end
end
