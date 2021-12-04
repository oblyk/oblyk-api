class AddFundingStatusAndNextVersionToGuideBookPapers < ActiveRecord::Migration[6.0]
  def change
    add_column :guide_book_papers, :funding_status, :string
    add_reference :guide_book_papers, :next_guide_book_paper, references: :guide_book_papers, index: true
  end
end
