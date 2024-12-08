class AddAscentTimeToContestAscents < ActiveRecord::Migration[6.0]
  def change
    add_column :contest_participant_ascents, :ascent_time, :time, precision: 3
  end
end
