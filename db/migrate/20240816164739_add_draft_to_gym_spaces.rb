class AddDraftToGymSpaces < ActiveRecord::Migration[6.0]
  def change
    remove_column :gym_spaces, :published_at
    add_column :gym_spaces, :archived_at, :datetime, after: :deleted_at
    add_column :gym_spaces, :draft, :boolean, default: false, after: :archived_at
  end
end
