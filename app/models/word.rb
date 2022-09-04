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
    {
      id: id,
      name: name,
      slug_name: slug_name,
      definition: definition
    }
  end

  def detail_to_json
    summary_to_json.merge(
      {
        versions_count: versions.length,
        creator: user&.summary_to_json(with_avatar: false),
        history: {
          created_at: created_at,
          updated_at: updated_at
        }
      }
    )
  end

  private

  def search_indexes
    [{ value: name, column_names: %i[name] }]
  end
end
