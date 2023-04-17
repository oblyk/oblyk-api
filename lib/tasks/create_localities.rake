# frozen_string_literal: true

namespace :create_localities do
  desc 'Create new localities'
  task :exec, %i[dry_run out] => :environment do |_t, args|
    out = args[:out] || $stdout
    dry_run = args[:dry_run] != 'false'

    out.puts '(dry_run)' if dry_run

    users = User.where(deleted_at: nil).where.not(partner_latitude: nil)
    users_count = users.count
    out.puts "Création de #{users.count} locality users"

    index = 0
    users.find_each do |user|
      index += 1
      out.puts "#{index}/#{users_count} User: #{user.full_name} (#{user.id})"
      locality_user = LocalityUser.new(user: user, latitude: user.partner_latitude, longitude: user.partner_longitude, local_sharing: true, partner_search: true)
      locality_user.create_by_reverse_geocoding! unless dry_run
    end

    out.puts 'End'
  end

  task :update_last_check, %i[out] => :environment do |_t, args|
    out = args[:out] || $stdout
    users = User.all
    user_count = users.count

    out.puts "Mise à jour de #{user_count} utilisateur"

    loop_index = 0
    users.find_each do |user|
      loop_index += 1
      out.puts "#{loop_index} / #{user_count} : Maj de #{user.first_name}"
      user.update_column :last_partner_check_at, user.last_activity_at
    end

    out.puts 'End'
  end
end
