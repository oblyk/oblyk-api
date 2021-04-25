class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications do |t|
      t.string :notification_type
      t.references :user
      t.references :notifiable, polymorphic: true

      t.datetime :posted_at
      t.datetime :read_at
      t.timestamps
    end

    add_index :notifications, :posted_at
  end
end
