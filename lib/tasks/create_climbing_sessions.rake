# frozen_string_literal: true

namespace :create_climbing_sessions do
  desc 'Create missing climbing sessions'
  task :run, %i[dry_run out] => :environment do |_t, args|
    out = args[:out] || $stdout
    dry_run = args[:dry_run] != 'false'

    out.puts '(dry_run)' if dry_run

    ascents = Ascent.where(climbing_session_id: nil)
    out.puts "#{ascents.count} to process"

    ascents.find_each do |ascent|
      climbing_session_found = ClimbingSession.find_or_initialize_by session_date: ascent.released_at, user_id: ascent.user_id

      if dry_run
        out.puts "ascent_id : #{ascent.id}"
      else
        climbing_session_found.save
        ascent.update_column :climbing_session_id, climbing_session_found.id
        out.puts "climbing_session_id : #{climbing_session_found.id}"
      end
    end

    out.puts 'End'
  end
end
