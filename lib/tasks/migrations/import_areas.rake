# frozen_string_literal: true

namespace :import do
  task :areas, %i[database out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym
    errors = []

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    all_old_data = import_db.execute('SELECT * FROM massives').to_a

    # 0 : id
    # 1 : user_id
    # 2 : label
    # 3 : views
    # 4 : created_at
    # 5 : updated_at

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[1]}"

      user = User.find_by legacy_id: data[2]

      area = Area.new(
        id: data[0],
        name: data[2],
        user: user,
        legacy_id: data[0],
        created_at: data[4],
        updated_at: data[5]
      )

      errors << "#{data[0]} : #{area.errors.full_messages}" unless area.save
    end

    out.puts ''
    out.puts 'Errors list :'
    errors.each do |error|
      out.puts error
    end

    out.puts ''
    out.puts 'end'
  end

  task :area_crags, %i[database out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym
    errors = []

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    all_old_data = import_db.execute('SELECT * FROM massive_crags').to_a

    # 0 : id
    # 1 : user_id
    # 2 : massive_id
    # 3 : crag_id
    # 4 : created_at
    # 5 : updated_at

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[1]}"

      user = User.find_by legacy_id: data[1]
      area = Area.find_by legacy_id: data[2]
      crag = Crag.find_by legacy_id: data[3]

      area_crag = AreaCrag.new(
        crag: crag,
        area: area,
        user: user,
        created_at: data[4],
        updated_at: data[5]
      )

      errors << "#{data[0]} : #{area_crag.errors.full_messages}" unless area_crag.save
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
