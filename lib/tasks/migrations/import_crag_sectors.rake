# frozen_string_literal: true

namespace :import do
  task :crag_sectors, %i[database out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    orientations_data = import_db.execute('SELECT * FROM orientations').to_a
    all_old_data = import_db.execute('SELECT * FROM sectors').to_a

    # 0 : id
    # 1 : crag_id
    # 2 : user_id
    # 3 : label
    # 4 : approach
    # 5 : rain_id
    # 6 : sun_id
    # 7 : lat
    # 8 : lng
    # 9 : created_at
    # 10 : updated_at

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[1]}"

      orientation = []
      orientations_data.each do |orientation_data|
        if orientation_data[1] == data[0] && orientation_data[2] == 'App\Sector'
          orientation = orientation_data
          break
        end
      end

      rain = nil
      rain = 'protected' if data[5] == 2
      rain = 'exposed' if data[5] == 3

      sun = nil
      sun = 'sunny_all_day' if data[6] == 2
      sun = 'shady' if data[6] == 3
      sun = 'sunny_afternoon' if data[6] == 4
      sun = 'sunny_morning' if data[6] == 5

      user = User.find_by legacy_id: data[2]
      crag = Crag.find_by legacy_id: data[1]

      latitude = data[7] != 0 ? data[7] : nil
      longitude = data[8] != 0 ? data[8] : nil

      sector = CragSector.new(
        name: data[3],
        description: nil,
        rain: rain,
        sun: sun,
        latitude: latitude,
        longitude: longitude,
        north: orientation[3],
        north_east: orientation[7],
        east: orientation[4],
        south_east: orientation[9],
        south: orientation[5],
        south_west: orientation[10],
        west: orientation[6],
        north_west: orientation[8],
        user: user,
        crag: crag,
        legacy_id: data[0],
        created_at: data[9],
        updated_at: data[10]
      )

      binding.pry unless sector.save
    end

    out.puts 'End'
  end
end
