# frozen_string_literal: true
module LogBook
  module Outdoor
    class CragFilteredAscents
      # This class is used to filter the ascents of a user based on filters extracted from params.
      attr_reader :ascents

      # Default values for the filters
      DEFAULTS_FILTERS = {
        :ascent_status_list => AscentStatus::LIST, # ['sent', 'red_point', 'flash', 'repetition']
        :roping_status_list => RopingStatus::LIST, # ['lead_climb', 'top_rope', ...]
        :climbing_types_list => Climb::CRAG_LIST,  # ['sport_climbing', 'bouldering', ...]
      }.freeze

      def initialize(user, params)
        @user = user
        @filters = filters_from_params(params)
        @ascents = @user.ascent_crag_routes.made.filtered(@filters)
      end

      private
      def filters_from_params(params)
        filters_params = JSON.parse(params[:filters]).transform_keys(&:to_sym)
        Rails.logger.debug "Filters params: #{filters_params}"
        filters = ActionController::Parameters.new(filters_params).permit(
          ascent_status_list: [],
          roping_status_list: [],
          climbing_types_list: []
        )
        # Merge with defaults
        # reverse_merge only adds default values for keys that are not yet present in `filters`.
        filters.reverse_merge(DEFAULTS_FILTERS)
      end
    end
  end
end
