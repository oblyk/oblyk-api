class CreateGymSpaceGroups < ActiveRecord::Migration[6.0]
  def change
    create_table :gym_space_groups do |t|
      t.references :gym
      t.string :name
      t.integer :order
      t.timestamps
    end

    add_reference :gym_spaces, :gym_space_group
  end
end
