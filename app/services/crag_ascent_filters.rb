# app/services/filter.rb
class CragAscentFilters
  # This class is used to filter the ascents of a user based on several criteria.
  # Some filters are applied directly in the database query (ActiveRecords in scope),
  # others are applied in Ruby (eg no_double filter with a uniq method).
  # filtered_ascents_array is an array of AscentCragRoute objects after applying all filters
  # filtered_ascents_active_record is an ActiveRecord::Relation after applying only the filters that can be applied in the database query
  attr_reader :filtered_ascents_array, :filtered_ascents_active_record

  # List of filter keys
  FILTER_LIST = %i[
    only_lead_climbs
    only_on_sight
    no_double
    climbing_type_filter
  ].freeze

  # Default values for the filters
  DEFAULTS = {
    only_lead_climbs: false,
    only_on_sight: false,
    no_double: false, # filter out repetitions and only keep the last ascent if there are multiple ascents of the same route
    climbing_type_filter: 'all' # filter among the climbing types Climb::CRAG_LIST
  }.freeze

  def initialize(user, params)
    @use_cache = true # TODO decide here if use cache or not
    @user = user
    @filters = filters_from_params(params)
    @filtered_ascents_array = @use_cache ? filtered_ascents_array_with_cache : filtered_ascents_array_from_db
    @filtered_ascents_active_record = @user.ascent_crag_routes.made.filtered(@filters)
  end

  private

  def filters_from_params(params)
    # ActionController::API does not parse JSON params in the second nested level into a Hash. We need to do it ourselves.
    # We parse the JSON string into a Ruby Hash.
    # ATTENTION: doing this transforms 'true' and 'false' strings into true and false booleans.
    # If parse fails, we set filters to default
    @filters = JSON.parse(params[:filters]) rescue {}

    FILTER_LIST.each_with_object({}) do |key, result|
      result[key] = extract_one_filter(key, DEFAULTS[key])
    end
  end

  def extract_one_filter(key, default)
    @filters&.fetch(key.to_s, default)
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
    if @filters[:no_double]
      @user.ascent_crag_routes.made.filtered(@filters).uniq(&:crag_route_id)
    else
      @user.ascent_crag_routes.made.filtered(@filters).to_a
    end
  end

end
