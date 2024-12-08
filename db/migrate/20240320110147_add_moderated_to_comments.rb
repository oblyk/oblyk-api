class AddModeratedToComments < ActiveRecord::Migration[6.0]
  def change
    add_column :comments, :moderated_at, :datetime
    add_column :gym_administrators, :subscribe_to_comment_feed, :boolean
    add_column :gym_administrators, :subscribe_to_video_feed, :boolean
    add_column :gym_administrators, :subscribe_to_follower_feed, :boolean
    add_column :gym_administrators, :last_comment_feed_read_at, :datetime
    add_column :gym_administrators, :last_video_feed_read_at, :datetime
    add_column :gym_administrators, :last_follower_feed_read_at, :datetime
  end
end
