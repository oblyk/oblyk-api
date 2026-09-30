class CreateCragProtections < ActiveRecord::Migration[8.1]
  def change
    # Crag route grade protection level
    # 0 : nothing needed, no account, no guide book, etc.
    # 1 : exemple : juste need account (actual default)
    # 2 : need engagement, like 'checkbox'
    # 3 : need secret question
    # 4 : need something like "proof of purchase"
    # 10 : no one can see grade
    add_column :crags, :grade_protection_level, :integer, default: 1

    create_table :user_crag_declarations do |t|
      t.references :crag, foreign_key: true
      t.references :user, foreign_key: true
      t.references :guide_book_paper, foreign_key: true # if secret question is used
      t.string :declaration_system # engament, secret_question, proof_of_purchase
      t.integer :equivalent_level
      t.datetime :declared_at
      t.timestamps
    end

    add_index :user_crag_declarations, %i[crag_id user_id], unique: true

    create_table :guide_book_paper_questions do |t|
      t.references :guide_book_paper, foreign_key: true
      t.text :question
      t.text :answer
      t.timestamps
    end
  end
end
