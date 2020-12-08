class CreateGymGrades < ActiveRecord::Migration[6.0]
  def change
    create_table :gym_grades do |t|
      t.string :name
      t.string :difficulty_system
      t.boolean :has_hold_color

      t.references :gym

      t.bigint :legacy_id
      t.timestamps
    end
  end
end
