class AddApproachTimesToCrags < ActiveRecord::Migration[6.0]
  def change
    add_column :crags, :min_approach_time, :integer
    add_column :crags, :max_approach_time, :integer

    add_column :approaches, :from_park, :boolean, default: true
  end
end
