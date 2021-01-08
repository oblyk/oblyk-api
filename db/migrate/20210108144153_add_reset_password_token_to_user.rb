class AddResetPasswordTokenToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :reset_password_token, :string
    add_column :users, :reset_password_token_expired_at, :datetime
  end
end
