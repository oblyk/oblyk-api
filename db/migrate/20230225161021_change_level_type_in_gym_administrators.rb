class ChangeLevelTypeInGymAdministrators < ActiveRecord::Migration[6.0]
  def change
    remove_column :gym_administrators, :level
    add_column :gym_administrators, :roles, :json
    add_column :gym_administrators, :requested_email, :string
  end
end
