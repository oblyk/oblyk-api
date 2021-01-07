class AddLocalizationToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :localization, :string
  end
end
