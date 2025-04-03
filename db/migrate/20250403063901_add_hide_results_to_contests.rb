class AddHideResultsToContests < ActiveRecord::Migration[6.0]
  def change
    add_column :contests, :hide_results, :boolean, default: false, after: :private
  end
end
