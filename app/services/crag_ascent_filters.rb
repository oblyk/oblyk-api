# app/services/filter.rb
class CragAscentFilters
  # This class is used to filter the ascents of a user based on several criteria.
  # Some filters are applied directly in the database query (ActiveRecords in scope),
  # others are applied in Ruby (eg no_double filter with a uniq method).
  # filtered_ascents_array is an array of AscentCragRoute objects after applying all filters
  # filtered_ascents_active_record is an ActiveRecord::Relation after applying only the filters that can be applied in the database query
  attr_reader :filtered_ascents_array, :filtered_ascents_active_record

  # Default values for the filters
  # other filters : list of filters that are not directly applied in the database query
  # but in Ruby (eg no_double filter with a uniq method)
  # for now, only "no_double" filter is in this list
  DEFAULTS_FILTERS = {
    "ascentStatusList" => AscentStatus::LIST, # ['sent', 'red_point', 'flash', 'repetition']
    "ropingStatusList" => RopingStatus::LIST, # ['lead_climb', 'top_rope', ...]
    "climbingTypesList" => Climb::CRAG_LIST,  # ['sport_climbing', 'bouldering', ...]
    "otherFilters" => ["no_double"]
  }.freeze

  def initialize(user, params)
    @use_cache = true # TODO decide here if use cache or not
    @user = user
    @filters = filters_from_params(params)
    Rails.logger.info("filters: #{@filters}") # TODO remove this line
    @filtered_ascents_array = @use_cache ? filtered_ascents_array_with_cache : filtered_ascents_array_from_db
    # WARNING: filtered_ascents_active_record does not include the otherFilters (ie no_double)
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

  # use cache to accelerate the process. SQL requests are called several times for each function from separate apis
  def filters_hash
    Digest::MD5.hexdigest(@filters.to_json)
  end

  # Cache filtered_ascents based on user and filters
  def filtered_ascents_array_with_cache
    cache_key = "filtered_ascents/#{@user.id}/#{filters_hash}"
    # TODO ajuster le temps de cache mais il doit être court, juste le temps de passer toutes les requetes de la page
    #  sinon ca ne mettra pas a jour les données si par exemple le user ajoute une nouvelle ascent
    Rails.cache.fetch(cache_key, expires_in: 30.seconds) do
      filtered_ascents_array_from_db
    end
  end

  # build the ActiveRecord query to get the filtered ascents array from the database
  def filtered_ascents_array_from_db
    # no_double filter as an ActiveRecord scope would be more slow as sql query. So we do it outside ascent.rb scope
    # we order according to roping_status and ascent_status in order to keep the "best" ascent
    if @filters["otherFilters"].include?("no_double")
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
