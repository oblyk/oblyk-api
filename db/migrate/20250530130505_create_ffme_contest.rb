class CreateFfmeContest < ActiveRecord::Migration[6.0]
  def change
    create_table :user_applications do |t|
      t.references :user, foreign_key: true
      t.string :type
      t.string :user_application_id, index: true
      t.string :status
      t.string :ffme_licence_number
      t.json :meta_data
      t.timestamps
    end

    add_index :user_applications, %i[type user_id], unique: true

    create_table :ffme_contests do |t|
      t.references :contest, foreign_key: true, unique: true
      t.string :status
      t.string :contest_type
      t.string :name
      t.string :description, limit: 2048
      t.date :start_date
      t.date :end_date
      t.string :contact_email
      t.string :contact_phone
      t.bigint :external_ffme_contest_id
      t.date :results_send_at
      t.timestamps
    end

    add_column :contest_participants, :synchronise_with_ffme_contest, :boolean
    add_column :gyms, :insee_code, :string
  end
end
