# frozen_string_literal: true

class Word < ApplicationRecord
  include Slugable
  include Searchable
  include ParentFeedable
  include ActivityFeedable

  has_paper_trail only: %i[name definition], if: proc { |_obj| ENV['PAPER_TRAIL'] == 'true' }

  has_one_attached :picture
  belongs_to :user, optional: true
  has_many :reports, as: :reportable

  validates :name, :definition, presence: true

  default_scope { order(:name) }

  def summary_to_json
    JSON.parse(
      ApplicationController.render(
        template: 'api/v1/words/summary.json',
        assigns: { word: self }
      )
    )
  end

  private

  def sonic_indexes
    [{ bucket: 'all', value: name }]
  end
end
