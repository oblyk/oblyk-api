# frozen_string_literal: true

class GuideBookPaperCrag < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :crag
  belongs_to :guide_book_paper

  validates :crag, uniqueness: { scope: :guide_book_paper }

  after_create :historize_around_towns
  after_create :touch_guide_book
  after_destroy :touch_guide_book

  private

  def touch_guide_book
    guide_book_paper.touch
  end

  def historize_around_towns
    HistorizeTownsAroundWorker.perform_in(1.hour, crag.latitude, crag.longitude, Time.current)
  end
end
