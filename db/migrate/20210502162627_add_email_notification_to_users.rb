class AddEmailNotificationToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :email_notifiable_list, :json
  end
end
