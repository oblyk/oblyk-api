class AddRakingTypeToGyms < ActiveRecord::Migration[6.0]
  def change
    add_column :gyms, :boulder_ranking, :string, after: :training_space
    add_column :gyms, :pan_ranking, :string, after: :training_space
    add_column :gyms, :sport_climbing_ranking, :string, after: :training_space
  end
end
