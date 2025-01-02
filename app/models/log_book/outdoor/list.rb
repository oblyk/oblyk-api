# frozen_string_literal: true

module LogBook
  module Outdoor
    class List
      def initialize(ascents)
        @ascents = ascents
      end

      def ascended_crag_routes(page, order)
        ascents = @ascents.joins(crag_route: :crag)
                                  .includes(
                                    crag_route: {
                                      crag_sector: { photo: { picture_attachment: :blob } },
                                      crag: { photo: { picture_attachment: :blob } },
                                      photo: { picture_attachment: :blob }
                                    },
                                    )

        ascents = case order
                  when 'crags'
                    ascents.order('crags.name, crag_routes.name, crag_routes.id')
                  when 'released_at'
                    ascents.order('ascents.released_at DESC, crag_routes.name, crag_routes.id')
                  else
                    ascents.order('ascents.max_grade_value DESC, crag_routes.name, crag_routes.id')
                  end

        ascents = ascents.page(page)
        ascent_routes = []
        ascents.each do |ascent|
          route = ascent.crag_route.summary_to_json(with_crag_in_sector: false)
          route[:grade_gap][:max_grade_value] = ascent.max_grade_value
          route[:grade_gap][:min_grade_value] = ascent.min_grade_value
          route[:grade_gap][:max_grade_text] = ascent.max_grade_text
          route[:grade_gap][:min_grade_text] = ascent.min_grade_text
          route[:released_at] = ascent.released_at
          ascent_routes << route
        end

        ascent_routes
      end
    end
  end
end

