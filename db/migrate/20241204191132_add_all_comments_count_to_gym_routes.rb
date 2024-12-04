class AddAllCommentsCountToGymRoutes < ActiveRecord::Migration[6.0]
  def change
    add_column :gym_routes, :all_comments_count, :integer, default: 0, after: :comments_count
  end
end
