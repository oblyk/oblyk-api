class AddWsTokenToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :ws_token, :string
    add_index :users, :ws_token, unique: true
  end
end
