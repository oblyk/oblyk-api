class AddCombinedRankingTypeToContests < ActiveRecord::Migration[6.0]
  def change
    add_column :contests, :combined_ranking_type, :string
  end
end
