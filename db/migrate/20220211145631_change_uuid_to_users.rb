class ChangeUuidToUsers < ActiveRecord::Migration[6.0]
  def change
    change_column :users, :uuid, :string, limit: 36
  end
end
