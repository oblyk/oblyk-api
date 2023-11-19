class AddAdditionalTimeToContests < ActiveRecord::Migration[6.0]
  def change
    add_column :contest_time_blocks, :additional_time, :integer, default: 20, after: :end_date
    add_column :contest_route_groups, :additional_time, :integer, default: 20, after: :end_date
  end
end
