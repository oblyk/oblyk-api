class CreateConversations < ActiveRecord::Migration[6.0]
  def change
    create_table :conversations do |t|
      t.bigint :legacy_id
      t.timestamps
    end

    create_table :conversation_users do |t|
      t.references :conversation
      t.references :user

      t.datetime :last_read_at

      t.bigint :legacy_id
      t.timestamps
    end

    create_table :conversation_messages do |t|
      t.text :body

      t.references :conversation
      t.references :user

      t.bigint :legacy_id
      t.datetime :posted_at
      t.timestamps
    end
  end
end
