class AddViewsToFollows < ActiveRecord::Migration[6.0]
  def change
    add_column :follows, :views, :integer, default: 0
  end
end
