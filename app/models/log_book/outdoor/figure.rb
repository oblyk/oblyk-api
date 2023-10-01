# frozen_string_literal: true

module LogBook
  module Outdoor
    class Figure
      attr_accessor :user

      def initialize(user)
        @user = user
      end

      def figures(only_lead_climbs=false)
        {
          countries: countries_count,
          regions: regions_count,
          crags: crags_count,
          ascents: ascents_count(only_lead_climbs),
          meters: sum_meters(only_lead_climbs),
          max_grade_value: max_grad_value(only_lead_climbs)
        }
      end

      private

      def uniq_ascent_crag_routes(only_lead_climbs=false)
        if only_lead_climbs == "true"
          @user.ascent_crag_routes.made.lead.uniq(&:crag_route_id)
        else
          @user.ascent_crag_routes.made.uniq(&:crag_route_id)
        end
      end

      def ascents_count(only_lead_climbs=false)
        uniq_ascent_crag_routes(only_lead_climbs).count
      end

      def sum_meters(only_lead_climbs=false)
        height_climbed = 0
        uniq_ascent_crag_routes(only_lead_climbs).each do |ascent|
          sections_heights = ascent.sections.map {|section| section['height']}.compact
          if sections_heights.size > 0   # si les hauteurs des sections d'une GV ne sont pas renseignées
            height_climbed += sections_heights.sum
          else
            height_climbed += ascent.height # on prend la hauteur totale de la GV
          end
        end
        height_climbed
      end

      def max_grad_value(only_lead_climbs=false)
        uniq_ascent_crag_routes(only_lead_climbs).map(&:max_grade_value).max
      end

      def countries_count
        @user.ascended_crags.distinct.count(:country)
      end

      def regions_count
        @user.ascended_crags.distinct.count(:region)
      end

      def crags_count
        @user.ascended_crags.distinct.count(:name)
      end
    end
  end
end

