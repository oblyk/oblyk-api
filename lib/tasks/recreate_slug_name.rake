# frozen_string_literal: true

namespace :recreate_slug_name do
  desc 'Slug Name refactor'
  task :exec, %i[dry_run out] => :environment do |_t, args|
    out = args[:out] || $stdout
    dry_run = args[:dry_run] != 'false'

    out.puts '(dry_run)' if dry_run

    # Premiere passe on fait le slug avec nom et prenom
    User.where(deleted_at: nil).find_each do |user|
      user.update_column :slug_name, "#{user.first_name} #{user.last_name}".parameterize unless dry_run
    end

    # Deuxieme passage on de duplique
    User.where(deleted_at: nil).order(id: :desc).find_each do |user|
      user.slug_name = user.find_slug_name user.slug_name
      out.puts "User id : #{user.id} nouveau slug : #{user.slug_name}"

      user.save unless dry_run
    end

    out.puts 'End'
  end
end
