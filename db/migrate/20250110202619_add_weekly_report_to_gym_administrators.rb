class AddWeeklyReportToGymAdministrators < ActiveRecord::Migration[6.0]
  def change
    add_column :gym_administrators, :weekly_report, :boolean, default: true
  end
end
