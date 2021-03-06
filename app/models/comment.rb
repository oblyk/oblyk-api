# frozen_string_literal: true

class Comment < ApplicationRecord
  include StripTagable

  belongs_to :user, optional: true
  belongs_to :commentable, polymorphic: true, counter_cache: :comments_count, touch: true
  has_many :reports, as: :reportable

  validates :body, presence: true
  validates :commentable_type, inclusion: { in: %w[Crag CragSector CragRoute GuideBookPaper Area Gym GymRoute Article].freeze }

  def summary_to_json
    detail_to_json
  end

  def detail_to_json
    {
      id: id,
      body: body,
      creator: user&.summary_to_json,
      history: {
        created_at: created_at,
        updated_at: updated_at
      }
    }
  end
end
