# frozen_string_literal: true

namespace :import do
  task :gym_spaces, %i[database storage_path out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym
    storage_path = args[:storage_path]
    errors = []

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    all_old_data = import_db.execute('SELECT * FROM gym_rooms').to_a

    # 0 : id
    # 1 : gym_id
    # 2 : gym_grade_id
    # 3 : label
    # 4 : description
    # 5 : banner_color
    # 6 : banner_bg_color
    # 7 : banner_opacity
    # 8 : scheme_bg_color
    # 9 : scheme_height
    # 10 : scheme_width
    # 11 : lat
    # 12 : lng
    # 13 : order
    # 14 : preferred_type
    # 15 : deleted_at
    # 16 : created_at
    # 17 : updated_at
    # 18 : published_at

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[3]}"

      gym = Gym.find_by legacy_id: data[1]
      gym_grade = GymGrade.find_by legacy_id: data[2]

      climbing_type = 'sport_climbing'
      climbing_type = 'bouldering' if data[14] == 2
      climbing_type = 'sport_climbing' if data[14].zero?

      gym_space = GymSpace.new(
        name: data[3],
        description: data[4],
        order: data[13],
        climbing_type: climbing_type,
        gym: gym,
        gym_grade: gym_grade,
        legacy_id: data[0],
        published_at: data[18],
        created_at: data[16],
        updated_at: data[17]
      )

      if gym_space.save
        # Import plan
        if File.exist?("#{storage_path}/gyms/schemes/scheme-#{gym_space.legacy_id}.png")
          plan = File.open("#{storage_path}/gyms/schemes/scheme-#{gym_space.legacy_id}.png")
          gym_space.plan.attach(io: plan, filename: "plan-#{data[3]}.png")
        end
      else
        errors << "#{data[0]} : #{gym_space.errors.full_messages}"
      end
    end

    out.puts ''
    out.puts 'Errors list :'
    errors.each do |error|
      out.puts error
    end

    out.puts ''
    out.puts 'end'
  end

  task :gym_sectors, %i[database out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym
    errors = []

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    all_old_data = import_db.execute('SELECT * FROM gym_sectors').to_a

    # 0 : id
    # 1 : room_id
    # 2 : label
    # 3 : group_sector
    # 4 : description
    # 5 : area
    # 6 : height
    # 7 : preferred_type
    # 8 : gym_grade_id
    # 9 : created_at
    # 10 : updated_at

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[2]}"

      gym_space = GymSpace.find_by legacy_id: data[1]
      gym_grade = GymGrade.find_by legacy_id: data[8]

      climbing_type = 'sport_climbing'
      climbing_type = 'bouldering' if data[7] == 2
      climbing_type = 'sport_climbing' if data[7].zero?

      gym_sector = GymSector.new(
        name: data[2],
        description: data[4],
        group_sector_name: data[3],
        climbing_type: climbing_type,
        height: data[6],
        polygon: data[5],
        gym_space: gym_space,
        gym_grade: gym_grade,
        legacy_id: data[0],
        created_at: data[9],
        updated_at: data[10]
      )

      errors << "#{data[0]} : #{gym_sector.errors.full_messages}" unless gym_sector.save
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
