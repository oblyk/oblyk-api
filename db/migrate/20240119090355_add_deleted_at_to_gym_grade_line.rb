class AddDeletedAtToGymGradeLine < ActiveRecord::Migration[6.0]
  def change
    add_column :gym_grade_lines, :deleted_at, :datetime, after: :updated_at
  end
end
