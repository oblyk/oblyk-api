class AddContestIdOnEachContestTables < ActiveRecord::Migration[6.0]
  def change
    add_reference :contest_participants, :contest
    add_reference :contest_participant_steps, :contest
    add_reference :contest_participant_ascents, :contest

    add_reference :contest_judge_routes, :contest

    add_reference :contest_stage_steps, :contest
    add_reference :contest_time_blocks, :contest
    add_reference :contest_routes, :contest
    add_reference :contest_route_groups, :contest
    add_reference :contest_route_group_categories, :contest
  end
end
