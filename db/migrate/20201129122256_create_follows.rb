class CreateFollows < ActiveRecord::Migration[6.0]
  def change
    create_table :follows do |t|
      t.references :followable, polymorphic: true
      t.references :user

      t.datetime :accepted_at
      t.bigint :legacy_id
      t.timestamps
    end
  end
end
