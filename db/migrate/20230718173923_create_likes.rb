class CreateLikes < ActiveRecord::Migration[6.0]
  def change
    create_table :likes do |t|
      t.references :user, foreign_key: true
      t.references :likeable, polymorphic: true
      t.timestamps
    end

    add_column :gym_routes, :likes_count, :integer, after: :comments_count
    add_column :comments, :likes_count, :integer, after: :user_id
    add_column :photos, :likes_count, :integer, after: :illustrable_id
    add_column :videos, :likes_count, :integer, after: :viewable_id
    add_column :articles, :likes_count, :integer
  end
end
