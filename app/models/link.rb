# frozen_string_literal: true

class Link < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :linkable, polymorphic: true
  has_many :reports, as: :reportable

  validates :name, :url, presence: true
  validates :linkable_type, inclusion: { in: %w[Crag CragSector CragRoute GuideBookPaper Area].freeze }

  def summary_to_json
    detail_to_json
  end

  def detail_to_json
    {
      id: id,
      name: name,
      url: url,
      description: description,
      creator: {
        uuid: user&.uuid,
        name: user&.full_name,
        slug_name: user&.slug_name
      },
      history: {
        created_at: created_at,
        updated_at: updated_at
      }
    }
  end
end
