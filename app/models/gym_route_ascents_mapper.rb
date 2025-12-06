# frozen_string_literal: true

class GymRouteAscentsMapper
  attr_accessor :routes, :user

  def initialize(routes, user)
    self.routes = routes
    self.user = user
  end

  def map_ascents
    if routes.is_a?(Array)
      mapper
    else
      self.routes = [routes]
      mapper.first
    end
  end

  private

  def mapper
    user_ascents = AscentGymRoute.where(user_id: user.id, gym_route_id: routes.map { |route| route[:id] })
                                 .order('FIELD(ascent_status, "onsight", "flash", "red_point", "sent", "repetition", "project")')

    return routes unless user_ascents.size.positive?

    user_ascents.size.positive?
    user_ascents = user_ascents.group_by(&:gym_route_id)
    ascent_route_ids = user_ascents.map(&:first)
    routes.each do |route|
      next unless ascent_route_ids.include?(route[:id])

      route[:my_ascents] = user_ascents[route[:id]].map(&:logbook_summary_to_json)
    end

    routes
  end
end
