# frozen_string_literal: true
module LogBook
  module Outdoor
    class CragFilteredAscents
      # This class is used to filter the ascents of a user based on filters extracted from params.
      attr_reader :ascents

      # Default values for the filters
      DEFAULTS_FILTERS = {
        :ascent_filter => AscentStatus::LIST, # ['sent', 'red_point', 'flash', 'repetition']
        :roping_filter => RopingStatus::LIST, # ['lead_climb', 'top_rope', ...]
        :climbing_type_filter => Climb::CRAG_LIST,  # ['sport_climbing', 'bouldering', ...]
      }.freeze

      def initialize(user, params)
        @user = user
        @filters = filters_from_params(params)
        @ascents = @user.ascent_crag_routes.made.filtered(@filters)
      end

      private
      def filters_from_params(params)
        filters = {
          :ascent_filter => params[:ascent_filter],
          :roping_filter => params[:roping_filter],
          :climbing_type_filter => params[:climbing_type_filter]
        }
        # Merge with defaults
        # reverse_merge only adds default values for keys that are not yet present in `filters`.
        (filters || {}).reverse_merge(DEFAULTS_FILTERS)
      end
    end
  end
end

