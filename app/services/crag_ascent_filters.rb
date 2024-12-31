# frozen_string_literal: true

class CragAscentFilters
  # This class is used to filter the ascents of a user based on several criteria.
  # Some filters are applied directly in the database query (ActiveRecords in scope),
  # no_double filter is done in Ruby with a uniq method
  # filtered_ascents_array is an array of AscentCragRoute objects after applying all filters
  # filtered_ascents_active_record is an ActiveRecord::Relation after applying only the filters that can be applied in the database query (ie no no_double filter)
  attr_reader :filtered_ascents_array, :filtered_ascents_active_record

  # Default values for the filters
  DEFAULTS_FILTERS = {
    "ascentStatusList" => AscentStatus::LIST, # ['sent', 'red_point', 'flash', 'repetition']
    "ropingStatusList" => RopingStatus::LIST, # ['lead_climb', 'top_rope', ...]
    "climbingTypesList" => Climb::CRAG_LIST,  # ['sport_climbing', 'bouldering', ...]
    "no_double" => "false"
  }.freeze

  def initialize(user, params)
    @user = user
    @filters = filters_from_params(params)
    @filtered_ascents_array = get_filtered_ascents_array
    # WARNING: filtered_ascents_active_record does not include no_double filter
    @filtered_ascents_active_record = @user.ascent_crag_routes.made.filtered(@filters)
  end

  private

  def filters_from_params(params)
    # Parse `filters` if it’s a string
    filters = params[:filters]
    filters = JSON.parse(filters) if filters.is_a?(String)

    # Merge with defaults
    # reverse_merge only adds default values for keys that are not yet present in `filters`.
    (filters || {}).reverse_merge(DEFAULTS_FILTERS)
  end

  # build the ActiveRecord query to get the filtered ascents array from the database
  def get_filtered_ascents_array
    # no_double filter as an ActiveRecord scope would be more slow as sql query. So we do it outside ascent.rb scope
    # we order according to roping_status and ascent_status in order to keep the "best" ascent
    if @filters["no_double"] == true
      @user.ascent_crag_routes
           .made
           .filtered(@filters)
           .order(Arel.sql("CASE roping_status
                      WHEN 'lead_climb' THEN 1
                      WHEN 'multi_pitch_leader' THEN 2
                      WHEN 'multi_pitch_alternate_lead' THEN 3
                      ELSE 4
                      END"),
                  Arel.sql("CASE ascent_status
                      WHEN 'onsight' THEN 1
                      WHEN 'flash' THEN 2
                      WHEN 'red_point' THEN 3
                      WHEN 'sent' THEN 4
                      ELSE 4
                      END"))
           .uniq(&:crag_route_id)
    else
      @user.ascent_crag_routes.made.filtered(@filters).to_a
    end
  end

end
