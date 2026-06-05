class DropFeeds < ActiveRecord::Migration[6.0]
  def change
    drop_table :feeds
  end
end
