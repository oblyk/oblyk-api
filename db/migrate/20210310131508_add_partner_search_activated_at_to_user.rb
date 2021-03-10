class AddPartnerSearchActivatedAtToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :partner_search_activated_at, :datetime
  end
end
