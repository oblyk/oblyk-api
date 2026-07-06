class DropSearches < ActiveRecord::Migration[6.0]
  def change
    drop_table :searches
  end
end
