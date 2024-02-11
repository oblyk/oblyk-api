class AddTombolaWinnerToContestParticipants < ActiveRecord::Migration[6.0]
  def change
    add_column :contest_participants, :tombola_winner, :boolean, after: :contest_wave_id, default: false
  end
end
