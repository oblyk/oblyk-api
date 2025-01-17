class ChangeWeeklyReportToGymAdministrators < ActiveRecord::Migration[6.0]
  def change
    rename_column :gym_administrators, :weekly_report, :email_report
  end
end
