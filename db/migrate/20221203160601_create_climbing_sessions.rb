class CreateClimbingSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :climbing_sessions do |t|
      t.text :description
      t.date :session_date
      t.references :user
      t.timestamps
    end
    add_index :climbing_sessions, [:session_date]

    add_column :ascents, :quantity, :integer, default: 1
    add_reference :ascents, :climbing_session
  end
end
