# frozen_string_literal: true

namespace :refresh_data do
  task :crag, %i[out] => :environment do |_t, args|
    out = args[:out] || $stdout

    crag_count = Crag.all.count

    Crag.all.find_each do |crag|
      out.puts ''
      out.puts "#{crag.id} / #{crag_count} : Refresh crag #{crag.name}"

      out.puts ' -> update climbing type'
      crag.update_climbing_type!

      out.puts ' -> update grade gap'
      crag.update_gap!
    end

    out.puts 'End'
  end

  task :crag_sector, %i[out] => :environment do |_t, args|
    out = args[:out] || $stdout

    crag_sector_count = CragSector.all.count

    CragSector.all.find_each do |crag_sector|
      out.puts ''
      out.puts "#{crag_sector.id} / #{crag_sector_count} : Refresh crag sector #{crag_sector.name}"

      out.puts ' -> update grade gap'
      crag_sector.update_gap!
    end

    out.puts 'End'
  end

  task :crag_route, %i[out] => :environment do |_t, args|
    out = args[:out] || $stdout

    crag_route_count = CragRoute.all.count

    CragRoute.all.find_each do |crag_route|
      out.puts ''
      out.puts "#{crag_route.id} / #{crag_route_count} : Refresh crag route #{crag_route.name}"

      out.puts ' -> update from ascents'
      crag_route.update_form_ascents!

      out.puts ' -> set location'
      crag_route.set_location!
    end

    out.puts 'End'
  end
end
