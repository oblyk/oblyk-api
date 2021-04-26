# frozen_string_literal: true

namespace :reset_counters_cache do
  desc 'Reset crags counter cache'
  task :crags, %i[cache out] => :environment do |_t, args|
    out = args[:out] || $stdout
    cache = args[:cache].to_sym

    out.puts 'RESET CRAGS COUNTER CACHE'
    out.puts "Cache selected : #{cache}"
    out.puts ''

    index_count = Crag.all.count
    index = 0
    Crag.find_each do |crag|
      index += 1
      out.puts "  -> Crag #{index}/#{index_count} : #{crag.name} (#{crag.id})"
      Crag.reset_counters(crag.id, :comments) if %i[all comments].include? cache
      Crag.reset_counters(crag.id, :videos) if %i[all videos].include? cache
      Crag.reset_counters(crag.id, :photos) if %i[all photos].include? cache
      Crag.reset_counters(crag.id, :follows) if %i[all follows].include? cache
      Crag.reset_counters(crag.id, :articles) if %i[all articles].include? cache
    end

    out.puts ''
    out.puts 'End'
  end

  desc 'Reset crag sectors counter cache'
  task :crag_sectors, %i[cache out] => :environment do |_t, args|
    out = args[:out] || $stdout
    cache = args[:cache].to_sym

    out.puts 'RESET CRAG SECTORS COUNTER CACHE'
    out.puts "Cache selected : #{cache}"
    out.puts ''

    index_count = CragSector.all.count
    index = 0
    CragSector.find_each do |crag_sector|
      index += 1
      out.puts "  -> CragSector #{index}/#{index_count} : #{crag_sector.name} (#{crag_sector.id})"
      CragSector.reset_counters(crag_sector.id, :comments) if %i[all comments].include? cache
      CragSector.reset_counters(crag_sector.id, :photos) if %i[all photos].include? cache
    end

    out.puts ''
    out.puts 'End'
  end

  desc 'Reset crag routes counter cache'
  task :crag_routes, %i[cache out] => :environment do |_t, args|
    out = args[:out] || $stdout
    cache = args[:cache].to_sym

    out.puts 'RESET CRAG ROUTE COUNTER CACHE'
    out.puts "Cache selected : #{cache}"
    out.puts ''

    index_count = CragRoute.all.count
    index = 0
    CragRoute.find_each do |crag_route|
      index += 1
      out.puts "  -> CragRoute #{index}/#{index_count} : #{crag_route.name} (#{crag_route.id})"
      CragRoute.reset_counters(crag_route.id, :comments) if %i[all comments].include? cache
      CragRoute.reset_counters(crag_route.id, :videos) if %i[all videos].include? cache
      CragRoute.reset_counters(crag_route.id, :photos) if %i[all photos].include? cache
    end

    out.puts ''
    out.puts 'End'
  end

  desc 'Reset gyms counter cache'
  task :gyms, %i[cache out] => :environment do |_t, args|
    out = args[:out] || $stdout
    cache = args[:cache].to_sym

    out.puts 'RESET GYM COUNTER CACHE'
    out.puts "Cache selected : #{cache}"
    out.puts ''

    index_count = Gym.all.count
    index = 0
    Gym.find_each do |gym|
      index += 1
      out.puts "  -> Gym #{index}/#{index_count} : #{gym.name} (#{gym.id})"
      Gym.reset_counters(gym.id, :comments) if %i[all comments].include? cache
      Gym.reset_counters(gym.id, :videos) if %i[all videos].include? cache
      Gym.reset_counters(gym.id, :follows) if %i[all follows].include? cache
    end

    out.puts ''
    out.puts 'End'
  end

  desc 'Reset gym routes counter cache'
  task :gym_routes, %i[cache out] => :environment do |_t, args|
    out = args[:out] || $stdout
    cache = args[:cache].to_sym

    out.puts 'RESET GYM ROUTE COUNTER CACHE'
    out.puts "Cache selected : #{cache}"
    out.puts ''

    index_count = GymRoute.all.count
    index = 0
    GymRoute.find_each do |gym_route|
      index += 1
      out.puts "  -> GymRoute #{index}/#{index_count} : #{gym_route.name} (#{gym_route.id})"
      GymRoute.reset_counters(gym_route.id, :comments) if %i[all comments].include? cache
      GymRoute.reset_counters(gym_route.id, :videos) if %i[all videos].include? cache
    end

    out.puts ''
    out.puts 'End'
  end

  desc 'Reset users counter cache'
  task :users, %i[cache out] => :environment do |_t, args|
    out = args[:out] || $stdout
    cache = args[:cache].to_sym

    out.puts 'RESET USER COUNTER CACHE'
    out.puts "Cache selected : #{cache}"
    out.puts ''

    index_count = User.all.count
    index = 0
    User.find_each do |user|
      index += 1
      out.puts "  -> User #{index}/#{index_count} : #{user.email} (#{user.id})"
      User.reset_counters(user.id, :follows) if %i[all follows].include? cache
    end

    out.puts ''
    out.puts 'End'
  end

  desc 'Reset articles counter cache'
  task :articles, %i[cache out] => :environment do |_t, args|
    out = args[:out] || $stdout
    cache = args[:cache].to_sym

    out.puts 'RESET ARTICLE COUNTER CACHE'
    out.puts "Cache selected : #{cache}"
    out.puts ''

    index_count = Article.all.count
    index = 0
    Article.find_each do |article|
      index += 1
      out.puts "  -> Article #{index}/#{index_count} : #{article.name} (#{article.id})"
      Article.reset_counters(article.id, :comments) if %i[all comments].include? cache
      Article.reset_counters(article.id, :photos) if %i[all photos].include? cache
    end

    out.puts ''
    out.puts 'End'
  end
end
