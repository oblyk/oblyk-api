# frozen_string_literal: true

class Word < ApplicationRecord
  include Slugable
  include Searchable
  include ParentFeedable
  include ActivityFeedable
  include StripTagable

  has_paper_trail only: %i[name definition], if: proc { |_obj| ENV['PAPER_TRAIL'] == 'true' }

  has_one_attached :picture
  belongs_to :user, optional: true
  has_many :reports, as: :reportable

  validates :name, :definition, presence: true

  default_scope { order(:name) }

  def summary_to_json
    detail_to_json
  end

  def detail_to_json
    {
      id: id,
      name: name,
      slug_name: slug_name,
      definition: definition,
      versions_count: versions.length,
      creator: user&.summary_to_json,
      history: {
        created_at: created_at,
        updated_at: updated_at
      }
    }
  end

  private

  def search_indexes
    [{ value: name }]
  end
end
