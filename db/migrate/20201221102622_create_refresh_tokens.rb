class CreateRefreshTokens < ActiveRecord::Migration[6.0]
  def change
    create_table :refresh_tokens do |t|
      t.references :user

      t.string :token, index: true, unique: true
      t.string :user_agent, index: true
      t.timestamps
    end
  end
end
