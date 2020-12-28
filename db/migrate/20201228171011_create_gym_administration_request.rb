class CreateGymAdministrationRequest < ActiveRecord::Migration[6.0]
  def change
    create_table :gym_administration_requests do |t|
      t.references :gym
      t.references :user
      t.text :justification
      t.string :email
      t.string :first_name
      t.string :last_name
      t.timestamps
    end
  end
end
