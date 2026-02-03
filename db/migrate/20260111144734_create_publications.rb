class CreatePublications < ActiveRecord::Migration[6.0]
  def change
    create_table :publications do |t|
      t.references :publishable, polymorphic: true, index: true
      t.references :author, index: true, foreign_key: { to_table: :users }
      t.string :publishable_subject
      t.text :body, limit: 5000
      t.datetime :published_at, index: true
      t.datetime :last_updated_at
      t.integer :comments_count, default: 0
      t.integer :likes_count, default: 0
      t.integer :attachables_count
      t.json :attachable_types_count
      t.boolean :generated, default: false
      t.datetime :pined_at, index: true
      t.decimal :latitude, precision: 10, scale: 6, nil: true, index: true
      t.decimal :longitude, precision: 10, scale: 6, nil: true, index: true
      t.timestamps
    end

    create_table :publication_attachments do |t|
      t.references :publication, index: true, foreign_key: true
      t.references :attachable, polymorphic: true, index: { name: :index_publications_attachments_on_attachable_type_and_id }
    end

    create_table :publication_views do |t|
      t.references :publication, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.datetime :viewed_at
    end

    add_index :publication_views, [:user_id, :publication_id], unique: true

    add_column :gym_spaces, :svg_sectors, :text
    add_column :notifications, :email_notification_sent_at, :datetime, after: :read_at
  end
end
