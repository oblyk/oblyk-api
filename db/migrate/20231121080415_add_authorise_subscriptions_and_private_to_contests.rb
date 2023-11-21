class AddAuthoriseSubscriptionsAndPrivateToContests < ActiveRecord::Migration[6.0]
  def change
    add_column :contests, :authorise_public_subscription, :boolean, default: true
    add_column :contests, :private, :boolean, default: false
  end
end
