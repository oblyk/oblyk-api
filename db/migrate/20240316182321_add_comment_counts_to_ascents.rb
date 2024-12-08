class AddCommentCountsToAscents < ActiveRecord::Migration[6.0]
  def change
    add_column :ascents, :comments_count, :integer, after: :comment
  end
end
