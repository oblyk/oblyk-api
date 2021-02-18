class ChangePublicToUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :public
    add_column :users, :public_profile, :boolean
    add_column :users, :public_outdoor_ascents, :boolean
    add_column :users, :public_indoor_ascents, :boolean
  end
end
