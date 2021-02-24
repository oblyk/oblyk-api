class ChangeColumnsToUsers < ActiveRecord::Migration[6.0]
  def change
    change_column :users, :grade_max, :integer
    change_column :users, :grade_min, :integer
    add_column :users, :partner_latitude, :decimal, precision: 10, scale: 6, nil: true
    add_column :users, :partner_longitude, :decimal, precision: 10, scale: 6, nil: true
    add_column :users, :last_activity_at, :datetime
  end
end
