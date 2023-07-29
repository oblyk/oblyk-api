class AddCommentsCountAndReplyToComments < ActiveRecord::Migration[6.0]
  def change
    add_column :comments, :comments_count, :integer, after: :likes_count
    add_reference :comments, :reply_to_comment, after: :user_id
  end
end
