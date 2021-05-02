class CreateNewsletters < ActiveRecord::Migration[6.0]
  def change
    create_table :newsletters do |t|
      t.string :name
      t.string :slug_name
      t.text :body
      t.integer :photos_count

      t.datetime :sent_at
      t.timestamps
    end

    add_column  :subscribes,:complained_at, :datetime
  end
end
