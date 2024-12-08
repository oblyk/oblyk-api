class AddAscentsLimitToContestStageSteps < ActiveRecord::Migration[6.0]
  def change
    add_column :contest_stage_steps, :ascents_limit, :integer, after: :ranking_type
  end
end
