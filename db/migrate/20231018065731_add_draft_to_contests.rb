class AddDraftToContests < ActiveRecord::Migration[6.0]
  def change
    add_column :contests, :draft, :boolean
  end
end
