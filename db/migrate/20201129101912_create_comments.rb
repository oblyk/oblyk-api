class CreateComments < ActiveRecord::Migration[6.0]
  def change
    create_table :comments do |t|
      t.text :body

      t.references :commentable, polymorphic: true
      t.references :user

      t.bigint :legacy_id
      t.timestamps
    end
  end
end
