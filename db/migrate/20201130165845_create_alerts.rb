class CreateAlerts < ActiveRecord::Migration[6.0]
  def change
    create_table :alerts do |t|
      t.text :description
      t.string :alert_type

      t.references :user
      t.references :alertable, polymorphic: true

      t.datetime :alerted_at
      t.timestamps
    end
  end
end
