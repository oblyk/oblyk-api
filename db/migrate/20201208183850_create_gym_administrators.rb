class CreateGymAdministrators < ActiveRecord::Migration[6.0]
  def change
    create_table :gym_administrators do |t|
      t.references :user
      t.references :gym
      t.string :level
    end
  end
end
