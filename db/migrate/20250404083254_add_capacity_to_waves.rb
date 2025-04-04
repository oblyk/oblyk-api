class AddCapacityToWaves < ActiveRecord::Migration[6.0]
  def change
    add_column :contest_waves, :capacity, :integer
  end
end
