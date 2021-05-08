class CreateIpBlackLists < ActiveRecord::Migration[6.0]
  def change
    create_table :ip_black_lists do |t|
      t.string :ip
      t.text :params_sent
      t.integer :block_count
      t.datetime :blocked_at
      t.datetime :block_expired_at
    end

    add_index :ip_black_lists, :ip
    add_index :ip_black_lists, :block_expired_at
  end
end
