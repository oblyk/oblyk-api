# frozen_string_literal: true

namespace :create_publications do
  desc 'Create publications by model'
  task :for_model, %i[model out] => :environment do |_t, args|
    out = args[:out] || $stdout
    model = args[:model]

    klass = Object.const_get model
    count = klass.all.count
    start_time = Time.current

    out.puts ''
    out.puts "create publication for #{count} #{model}"

    object = case model
             when 'Crag'
               Crag.includes(:user)
             when 'Gym'
               Gym.includes(:user)
             when 'GuideBookPaper'
               GuideBookPaper.includes(:user)
             when 'Photo'
               Photo.includes(:illustrable)
             else
               klass
             end

    loop = 0
    object.all.find_each do |record|
      loop += 1
      out.puts "--> #{(loop.to_d / count.to_d * 100.0).round(2)}% create publication for #{record.id} #{record.name}"
      record.publication_push!
    end

    seconds = (start_time - Time.current).round
    minutes = (seconds.to_d / 60.0).round
    hours = (minutes.to_d / 60.0).round(1)
    out.puts "Finish on #{seconds} seconds, aka #{minutes} minutes, aka #{hours} hours"
    out.puts 'End'
  end

  desc 'Create publications for route'
  task :for_crag_routes, %i[out] => :environment do |_t, args|
    out = args[:out] || $stdout

    crags = Crag.includes(:crag_routes).all
    crags_count = crags.count
    start_time = Time.current

    out.puts ''
    out.puts "create publication for #{crags_count} crags"

    loop = 0
    crags.all.find_each do |crag|
      loop += 1
      out.puts "--> #{(loop.to_d / crags_count.to_d * 100.0).round(2)}% create publication for #{crag.id} #{crag.name}"

      route_by_dates = {}
      crag.crag_routes.select(:id, :created_at, :user_id).order(created_at: :desc).each do |route|
        created_at = route.created_at.beginning_of_week
        route_by_dates[created_at] ||= []
        route_by_dates[created_at] << route
      end
      route_by_dates.each do |_date, routes|
        publication = Publication.new(
          publishable_id: crag.id,
          publishable_type: 'Crag',
          publishable_subject: 'new_crag_routes',
          generated: true
        )
        routes.each do |route|
          publication.published_at = route.created_at
          publication.last_updated_at = route.created_at
          publication.author_id = route.user_id
          publication.publication_attachments << PublicationAttachment.new(attachable_type: 'CragRoute', attachable_id: route.id)
        end
        publication.save
      end
    end

    seconds = (start_time - Time.current).round
    minutes = (seconds.to_d / 60.0).round
    hours = (minutes.to_d / 60.0).round(1)
    out.puts "Finish on #{seconds} seconds, aka #{minutes} minutes, aka #{hours} hours"
    out.puts 'End'
  end
end
