class CreateGymClimbingStyles < ActiveRecord::Migration[6.0]
  def change
    create_table :gym_climbing_styles do |t|
      t.string :style
      t.string :climbing_type
      t.string :color
      t.references :gym
      t.datetime :deactivated_at
      t.timestamps
    end
  end
end
