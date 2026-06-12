class DropNewsletters < ActiveRecord::Migration[6.0]
  def change
    drop_table :newsletters
  end
end
