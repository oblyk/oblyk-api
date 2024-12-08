# frozen_string_literal: true

namespace :ascents_faker do
  desc 'Make random ascents on gym'
  task :gym_ascents, %i[gym_id base_user_id out] => :environment do |_t, args|
    out = args[:out] || $stdout

    gym = Gym.find args[:gym_id]
    base_user = User.find args[:base_user_id]
    users = base_user.follows.map(&:user)
    users << base_user

    users.each do |user|
      ## clear ascents gym route
      out.puts " -> Clear ascents gym route for #{user.first_name}"
      user.ascent_gym_routes.where(gym: gym).destroy_all

      stronger = rand(10..90)
      out.puts "    Stronger rate #{stronger}"
      gym.gym_routes.mounted.find_each do |gym_route|
        realised = chance(stronger)
        if realised
          ascent_status = AscentStatus::LIST.sample
          hardness_status = Hardness::LIST.dup
          20.times do
            hardness_status << nil
          end
          hardness_status = hardness_status.sample
          user.ascent_gym_routes << AscentGymRoute.new(
            ascent_status: ascent_status,
            hardness_status: hardness_status,
            gym_route: gym_route,
            gym: gym,
            released_at: Date.current,
            selected_sections: [0]
          )
        end
      end
    end
  end

  def chance(percent)
    rand(1..100) <= percent
  end
end
