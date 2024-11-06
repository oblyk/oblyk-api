class AddNameToContestStages < ActiveRecord::Migration[6.0]
  def change
    add_column :contest_stages, :name, :string, after: :climbing_type
  end
end
