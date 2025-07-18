class AddOptionalGenderToContests < ActiveRecord::Migration[6.0]
  def change
    add_column :contests, :optional_gender, :boolean, default: false
  end
end
