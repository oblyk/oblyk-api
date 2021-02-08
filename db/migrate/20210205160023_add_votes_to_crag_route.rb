class AddVotesToCragRoute < ActiveRecord::Migration[6.0]
  def change
    add_column :crag_routes, :votes, :json
  end
end
