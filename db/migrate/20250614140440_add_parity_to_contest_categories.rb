class AddParityToContestCategories < ActiveRecord::Migration[6.0]
  def change
    add_column :contest_categories, :parity, :boolean, default: false
  end
end
