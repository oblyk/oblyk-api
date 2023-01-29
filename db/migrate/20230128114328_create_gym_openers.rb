class CreateGymOpeners < ActiveRecord::Migration[6.0]
  def change
    create_table :gym_openers do |t|
      t.string :name
      t.string :first_name
      t.string :last_name
      t.string :slug_name
      t.string :email
      t.references :user
      t.references :gym
      t.datetime :deactivated_at
      t.timestamps
    end

    create_table :gym_route_openers do |t|
      t.references :gym_opener
      t.references :gym_route
      t.timestamps
    end
  end
end
