class AddTeamToContests < ActiveRecord::Migration[6.0]
  def change
    add_column :contests, :team_contest, :boolean, default: false
    add_column :contests, :participant_per_team, :integer, default: 0

    create_table :contest_teams do |t|
      t.references :contest
      t.string :name
      t.timestamps
    end

    add_index :contest_teams, [:name, :contest_id], unique: true
    add_reference :contest_participants, :contest_team
  end
end
