class CreateChampionships < ActiveRecord::Migration[6.0]
  def change
    create_table :championships do |t|
      t.string :name
      t.string :slug_name
      t.text :description
      t.string :combined_ranking_type
      t.references :gym, foreign_key: true
      t.timestamps
    end

    create_table :championship_contests do |t|
      t.references :contest, foreign_key: true
      t.references :championship, foreign_key: true
      t.timestamps
    end

    create_table :championship_categories do |t|
      t.string :name
      t.string :slug_name
      t.references :championship, foreign_key: true
      t.timestamps
    end

    create_table :championship_category_matches do |t|
      t.references :championship_category, foreign_key: true
      t.references :contest_category, foreign_key: true
      t.timestamps
    end
  end
end
