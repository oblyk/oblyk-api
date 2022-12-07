class CreateColorSystems < ActiveRecord::Migration[6.0]
  def change
    create_table :color_systems do |t|
      t.string :colors_mark
      t.timestamps
    end
    add_index :color_systems, :colors_mark, unique: true

    create_table :color_system_lines do |t|
      t.references :color_system
      t.string :hex_color
      t.integer :order
      t.timestamps
    end

    add_reference :ascents, :color_system_line
  end
end
