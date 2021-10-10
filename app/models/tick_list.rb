# frozen_string_literal: true

class TickList < ApplicationRecord
  belongs_to :user
  belongs_to :crag_route

  def summary_to_json
    detail_to_json
  end

  def detail_to_json
    {
      id: id,
      crag_route: {
        id: crag_route.id,
        name: crag_route.name
      },
      history: {
        created_at: created_at,
        updated_at: updated_at
      }
    }
  end
end
