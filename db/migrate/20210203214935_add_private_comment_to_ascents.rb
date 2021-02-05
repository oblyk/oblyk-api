class AddPrivateCommentToAscents < ActiveRecord::Migration[6.0]
  def change
    add_column :ascents, :private_comment, :boolean
  end
end
