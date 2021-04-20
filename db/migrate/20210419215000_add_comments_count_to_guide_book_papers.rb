class AddCommentsCountToGuideBookPapers < ActiveRecord::Migration[6.0]
  def change
    add_column :guide_book_papers, :comments_count, :integer
  end
end
