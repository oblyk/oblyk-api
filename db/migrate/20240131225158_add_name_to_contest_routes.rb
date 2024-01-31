class AddNameToContestRoutes < ActiveRecord::Migration[6.0]
  def change
    add_column :contest_routes, :name, :string, after: :number
  end
end
