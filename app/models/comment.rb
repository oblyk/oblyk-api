# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :commentable, polymorphic: true, counter_cache: :comments_count
  has_many :reports, as: :reportable

  validates :body, presence: true
  validates :commentable_type, inclusion: { in: %w[Crag CragSector CragRoute GuideBookPaper Area GymRoute].freeze }
end
