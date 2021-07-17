# frozen_string_literal: true

namespace :import do
  task :gyms, %i[database storage_path out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym
    storage_path = args[:storage_path]
    errors = []

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    all_old_data = import_db.execute('SELECT * FROM gyms').to_a

    # 0 : id
    # 1 : user_id
    # 2 : label
    # 3 : description
    # 4 : type_boulder
    # 5 : type_route
    # 6 : free
    # 7 : views
    # 8 : address
    # 9 : postal_code
    # 10 : code_country
    # 11 : country
    # 12 : city
    # 13 : big_city
    # 14 : region
    # 15 : lat
    # 16 : lng
    # 17 : email
    # 18 : phone_number
    # 19 : web_site
    # 20 : deleted_at
    # 21 : created_at
    # 22 : updated_at
    # 23 : type_pan
    # 24 : option_start_date
    # 25 : option_end_date
    # 26 : option_level

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[2]}"

      user = User.find_by legacy_id: data[1]

      latitude = data[15] != 0 ? data[15] : nil
      longitude = data[16] != 0 ? data[16] : nil

      address = data[8]
      address = '6 Boulevard Nicollet' if data[0] == 74
      address = 'Avenue de Luminy' if data[0] == 171
      address = 'Place du groupe scolaire' if data[0] == 176

      gym = Gym.new(
        id: data[0],
        name: data[2],
        description: data[3],
        address: address,
        postal_code: data[9],
        code_country: data[10],
        country: data[11],
        city: data[12],
        big_city: data[13],
        region: data[14],
        email: data[17],
        phone_number: data[18],
        web_site: data[19],
        bouldering: data[4],
        sport_climbing: data[5],
        pan: data[23],
        fun_climbing: false,
        training_space: false,

        latitude: latitude,
        longitude: longitude,
        user: user,

        plan: nil,
        plan_start_at: nil,
        plan_end_at: nil,
        assigned_at: nil,

        legacy_id: data[0],
        created_at: data[21],
        updated_at: data[22]
      )

      if gym.save
        # Import logo
        if File.exist?("#{storage_path}/gyms/100/logo-#{gym.legacy_id}.png")
          logo = File.open("#{storage_path}/gyms/100/logo-#{gym.legacy_id}.png")
          gym.logo.attach(io: logo, filename: "logo-#{gym.slug_name}.jpg")
        end

        # Import banner
        if File.exist?("#{storage_path}/gyms/1300/bandeau-#{gym.legacy_id}.jpg")
          banner = File.open("#{storage_path}/gyms/1300/bandeau-#{gym.legacy_id}.jpg")
          gym.banner.attach(io: banner, filename: "banner-#{gym.slug_name}.jpg")
        end
      else
        errors << "#{data[0]} : #{gym.errors.full_messages}"
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

  task :gym_administrators, %i[database out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym
    errors = []

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    all_old_data = import_db.execute('SELECT * FROM gym_administrators').to_a

    # 0 : id
    # 1 : gym_id
    # 2 : user_id
    # 3 : level
    # 4 : created_at
    # 5 : updated_at

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[1]}"

      user = User.find_by legacy_id: data[2]
      gym = Gym.find_by legacy_id: data[1]

      gym_administrator = GymAdministrator.new(
        gym: gym,
        user: user,
        level: data[3]
      )

      errors << "#{data[0]} : #{gym_administrator.errors.full_messages}" unless gym_administrator.save
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
