class Add3dParametersToGyms < ActiveRecord::Migration[6.0]
  def change
    add_column :gyms, :representation_type, :string, default: '2d_picture'
    add_column :gyms, :three_d_camera_position, :json
    add_column :gym_spaces, :three_d_parameters, :json
    add_column :gym_spaces, :three_d_position, :json
    add_column :gym_spaces, :three_d_scale, :decimal, precision: 10, scale: 6, nil: true, default: 1
    add_column :gym_spaces, :three_d_rotation, :json
    add_column :gym_spaces, :three_d_camera_position, :json
    add_column :gym_spaces, :representation_type, :string, default: '2d_picture'
    add_column :gym_sectors, :three_d_path, :json
    add_column :gym_sectors, :three_d_height, :decimal, precision: 10, scale: 6, nil: true

    create_table :gym_three_d_assets do |t|
      t.string :name
      t.string :slug_name
      t.text :description
      t.json :three_d_parameters
      t.references :gym, foreign_key: true
      t.timestamps
    end

    create_table :gym_three_d_elements do |t|
      t.json :three_d_position
      t.json :three_d_rotation
      t.text :message
      t.string :url
      t.decimal :three_d_scale, precision: 10, scale: 6, nil: true, default: 1
      t.references :gym_three_d_asset, foreign_key: true
      t.references :gym, foreign_key: true
      t.references :gym_space, foreign_key: true
      t.timestamps
    end
  end
end
