class AddAscentsMultiplierToGyms < ActiveRecord::Migration[6.0]
  def change
    add_column :gyms, :ascents_multiplier, :json, after: :boulder_ranking
    add_column :gym_levels, :enabled, :boolean, default: true, after: :climbing_type
  end
end
