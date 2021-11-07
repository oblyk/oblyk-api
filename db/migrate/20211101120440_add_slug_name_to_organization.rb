class AddSlugNameToOrganization < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :slug_name, :string
  end
end
