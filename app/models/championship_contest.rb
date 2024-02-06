# frozen_string_literal: true

class ChampionshipContest < ApplicationRecord
  belongs_to :contest
  belongs_to :championship

  before_destroy :destroy_category_matches

  private

  def destroy_category_matches
    championship.championship_categories.each do |championship_category|
      championship_category.championship_category_matches.each do |championship_category_match|
        championship_category_match.destroy if championship_category_match.contest_category.contest_id == contest_id
      end
    end
  end
end
