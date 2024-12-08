# frozen_string_literal: true

class ChampionshipCategoryMatch < ApplicationRecord
  belongs_to :championship_category
  belongs_to :contest_category
end
