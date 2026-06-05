# frozen_string_literal: true

class AreaCrag < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :crag
  belongs_to :area

  validates :crag_id, uniqueness: { scope: :area_id, case_sensitive: false }
end
