# app/services/filter.rb
class CragAscentFilter
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
    no_double: false, # filter out repetitions and only keep the first ascent if there are multiple ascents of the same route
    climbing_type_filter: 'all' # filter among the climbing types Climb::CRAG_LIST
  }.freeze

  def initialize(params)
    @params = params
  end

  def extract_filters
    FILTER_LIST.each_with_object({}) do |key, result|
      result[key] = extract_one_filter(key, DEFAULTS[key])
    end
  end

  private

  # ActionController::API does not parse JSON params nested second level into a Hash. We need to do it ourselves.
  def extract_one_filter(key, default)
    # Ensure filters is always a hash
    #Rails.logger.warn "Params before: #{@params}"
    filters = JSON.parse(@params[:filters]) rescue @params[:filters]
    #Rails.logger.warn "Filters after : #{filters} (type: #{filters.class})"
    filters&.fetch(key.to_s, default)
  end

end
