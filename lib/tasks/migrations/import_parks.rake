# frozen_string_literal: true

namespace :import do
  task :parks, %i[database out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    all_old_data = import_db.execute('SELECT * FROM parkings').to_a

    # 0 : id
    # 1 : crag_id
    # 2 : user_id
    # 3 : description
    # 4 : lat
    # 5 : lng
    # 6 : created_at
    # 7 : updated_at

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[1]}"

      user = User.find_by legacy_id: data[2]
      crag = Crag.find_by legacy_id: data[1]

      latitude = data[4] != 0 ? data[4] : nil
      longitude = data[5] != 0 ? data[5] : nil

      park = Park.new(
        description: data[3],
        latitude: latitude,
        longitude: longitude,
        user: user,
        crag: crag,
        legacy_id: data[0],
        created_at: data[6],
        updated_at: data[7]
      )

      binding.pry unless park.save
    end

    out.puts 'End'
  end
end
