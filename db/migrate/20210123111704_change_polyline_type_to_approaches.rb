class ChangePolylineTypeToApproaches < ActiveRecord::Migration[6.0]
  def change
    change_column :approaches, :polyline, :json
  end
end
