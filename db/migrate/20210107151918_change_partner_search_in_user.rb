class ChangePartnerSearchInUser < ActiveRecord::Migration[6.0]
  def change
    change_column_default :users, :partner_search, nil
    change_column_default :users, :public, nil
  end
end
