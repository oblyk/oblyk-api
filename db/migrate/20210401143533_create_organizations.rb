class CreateOrganizations < ActiveRecord::Migration[6.0]
  def change
    create_table :organizations do |t|
      t.string :name

      t.string :api_access_token
      t.string :api_usage_type
      t.string :api_outdoor_right
      t.string :api_indoor_right
      t.string :api_community_right

      t.string :phone
      t.string :email
      t.string :address
      t.string :city
      t.string :zipcode
      t.string :website
      t.string :company_registration_number

      t.timestamps
      t.datetime :deleted_at
    end

    add_index :organizations, :name, unique: true
    add_index :organizations, :api_access_token, unique: true

    create_table :organization_users do |t|
      t.references :organization
      t.references :user
      t.timestamps
    end

    create_table :organization_gyms do |t|
      t.references :organization
      t.references :gym
      t.timestamps
    end
  end
end
