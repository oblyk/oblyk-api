class CreateContestJudges < ActiveRecord::Migration[6.0]
  def change
    create_table :contest_judges do |t|
      t.string :name
      t.string :uuid, index: true
      t.string :code
      t.references :contest, null: false, foreign_key: true
      t.timestamps
    end

    create_table :contest_judge_routes do |t|
      t.references :contest_judge, null: false, foreign_key: true
      t.references :contest_route, null: false, foreign_key: true
      t.timestamps
    end
  end
end
