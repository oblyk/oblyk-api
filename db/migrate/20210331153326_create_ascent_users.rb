class CreateAscentUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :ascent_users do |t|
      t.references :user
      t.references :ascent

      t.timestamps
    end

    add_index :ascent_users, [:user_id, :ascent_id], unique: true
  end
end
