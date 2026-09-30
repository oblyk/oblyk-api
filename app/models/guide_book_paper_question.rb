# frozen_string_literal: true

class GuideBookPaperQuestion < ApplicationRecord
  belongs_to :guide_book_paper

  validates :question, :answer, presence: true
end
