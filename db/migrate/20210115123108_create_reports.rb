class CreateReports < ActiveRecord::Migration[6.0]
  def change
    create_table :reports do |t|
      t.string :report_from_url

      t.references :reportable, polymorphic: true

      t.text :body

      t.references :user

      t.datetime :processed_at
      t.timestamps
    end
  end
end
