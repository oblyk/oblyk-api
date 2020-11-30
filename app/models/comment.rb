# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :commentable, polymorphic: true

  validates :body, presence: true
  validates :commentable_type, inclusion: { in: %w[Crag CragSector CragRoute].freeze }
end
