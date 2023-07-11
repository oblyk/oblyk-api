# frozen_string_literal: true

namespace :migrate_gym_route_pictures do

  desc 'Create GymRouteCover form gym route picture attachments'
  task :exec, %i[out] => :environment do |_t, args|
    out = args[:out] || $stdout

    attachments = ActiveStorage::Attachment.where(record_type: 'GymRoute', name: 'picture')

    count = attachments.count
    loop_index = 0
    out.puts "migrate #{count} attachments"
    out.puts ''

    attachments.find_each do |attachment|
      loop_index += 1
      out.puts "Gym route picture #{loop_index} / #{count}"
      gym_route_id = attachment.record_id

      # Create GymRouteCover
      gym_route_cover = GymRouteCover.create

      # Change attachment record
      attachment.record_id = gym_route_cover.id
      attachment.record_type = 'GymRouteCover'
      attachment.save

      # Add GymRouteCover to GymRoute
      gym_route = GymRoute.find gym_route_id
      gym_route.gym_route_cover_id = gym_route_cover.id
      gym_route.save
    end

    out.puts ''
    out.puts 'end'
  end
end
