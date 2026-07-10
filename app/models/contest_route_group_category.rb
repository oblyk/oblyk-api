# frozen_string_literal: true

class ContestRouteGroupCategory < ApplicationRecord
  belongs_to :contest_category
  belongs_to :contest_route_group
  belongs_to :contest

  before_validation :set_contest
  after_save :delete_caches
  after_destroy :delete_caches

  private

  def set_contest
    self.contest ||= contest_category.contest
  end

  def delete_caches
    contest.delete_results_cache
  end
end
