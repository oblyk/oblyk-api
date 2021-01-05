class AddSlugNameToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :slug_name, :string
  end
end
