# frozen_string_literal: true

module Statistics
  class CragStatistic
    include RouteFigurable

    attr_accessor :crags

    def crag_routes
      CragRoute.where(crag_id: crags.pluck(:id))
    end
  end
end
