# frozen_string_literal: true

namespace :import do
  task :approaches, %i[database out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    all_old_data = import_db.execute('SELECT * FROM approaches').to_a

    # 0 : id
    # 1 : crag_id
    # 2 : user_id
    # 3 : polyline
    # 4 : description
    # 5 : length
    # 6 : created_at
    # 7 : updated_at

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[1]}"

      user = User.find_by legacy_id: data[2]
      crag = Crag.find_by legacy_id: data[1]

      polyline = "[#{data[3]}]"
      polyline = JSON.parse polyline

      approach = Approach.new(
        polyline: polyline,
        description: data[4],
        length: data[5],
        approach_type: nil,
        crag: crag,
        user: user,
        legacy_id: data[0],
        created_at: data[6],
        updated_at: data[7]
      )

      binding.pry unless approach.save
    end

    out.puts 'End'
  end
end
