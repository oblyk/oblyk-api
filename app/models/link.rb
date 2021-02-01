# frozen_string_literal: true

class Link < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :linkable, polymorphic: true
  has_many :reports, as: :reportable

  validates :name, :url, presence: true
  validates :linkable_type, inclusion: { in: %w[Crag CragSector CragRoute GuideBookPaper Area].freeze }
end
