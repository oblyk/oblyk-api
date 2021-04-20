class AddCommentsCountToGyms < ActiveRecord::Migration[6.0]
  def change
    add_column :gyms, :comments_count, :integer
  end
end
