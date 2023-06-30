class AddUserToRockBars < ActiveRecord::Migration[6.0]
  def change
    add_reference :rock_bars, :user, after: :crag_sector_id
  end
end
