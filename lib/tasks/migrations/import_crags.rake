# frozen_string_literal: true

namespace :import do
  task :crags, %i[database out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym
    errors = []

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    orientations_data = import_db.execute('SELECT * FROM orientations').to_a
    seasons_data = import_db.execute('SELECT * FROM seasons').to_a
    sectors_data = import_db.execute('SELECT * FROM sectors').to_a
    all_old_data = import_db.execute('SELECT * FROM crags').to_a

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[1]}"

      rocks = [
        nil,
        nil,
        'slate',
        'limestone',
        'conglomerate',
        'gabbro',
        'gneiss',
        'granite',
        'sandstone',
        'migmatite',
        'molasses',
        'quartzite',
        'serpentinite',
        'silex',
        'basalt',
        'rhyolite',
        'andesite',
        'schist',
        'phonolite'
      ]

      season = []
      seasons_data.each do |season_data|
        if season_data[1] == data[0] && season_data[2] == 'App\Crag'
          season = season_data
          break
        end
      end

      orientation = []
      orientations_data.each do |orientation_data|
        if orientation_data[1] == data[0] && orientation_data[2] == 'App\Crag'
          orientation = orientation_data
          break
        end
      end

      rain = nil
      sun = nil

      sectors_data.each do |sector_data|
        next unless sector_data[1] == data[0]

        rain = 'protected' if sector_data[5] == 2
        rain = 'exposed' if sector_data[5] == 3

        sun = 'sunny_all_day' if sector_data[6] == 2
        sun = 'shady' if sector_data[6] == 3
        sun = 'sunny_afternoon' if sector_data[6] == 4
        sun = 'sunny_morning' if sector_data[6] == 5

        break
      end

      user = User.find_by legacy_id: data[10]

      new_rocks = rocks[data[2]].present? ? [rocks[data[2]]] : []

      crag = Crag.new(
        id: data[0],
        legacy_id: data[0],
        user: user,
        name: data[1],
        rocks: new_rocks,
        rain: rain,
        sun: sun,
        latitude: data[11],
        longitude: data[12],
        code_country: data[6],
        country: data[7],
        city: data[8],
        region: data[9],
        sport_climbing: data[13],
        bouldering: data[15],
        multi_pitch: data[14],
        trad_climbing: nil,
        aid_climbing: nil,
        deep_water: data[16],
        via_ferrata: data[17],
        summer: season[3],
        autumn: season[4],
        winter: season[5],
        spring: season[6],
        north: orientation[3],
        north_east: orientation[7],
        east: orientation[4],
        south_east: orientation[9],
        south: orientation[5],
        south_west: orientation[10],
        west: orientation[6],
        north_west: orientation[8],
        created_at: data[19],
        updated_at: data[20]
      )

      errors << "#{data[0]} : #{crag.errors.full_messages}" unless crag.save
    end

    out.puts ''
    out.puts 'Errors list :'
    errors.each do |error|
      out.puts error
    end

    out.puts ''
    out.puts 'end'
  end
end
