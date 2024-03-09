class AddDeletedAtToContests < ActiveRecord::Migration[6.0]
  def change
    add_column :contests, :deleted_at, :datetime, after: :updated_at
    add_column :championships, :archived_at, :datetime, after: :gym_id
  end
end
