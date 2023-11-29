# frozen_string_literal: true

class ContestRouteGroupCategory < ApplicationRecord
  belongs_to :contest_category
  belongs_to :contest_route_group
  has_one :contest, through: :contest_category

  after_save :delete_caches
  after_destroy :delete_caches

  private

  def delete_caches
    contest.delete_results_cache
  end
end
