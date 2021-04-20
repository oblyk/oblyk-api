# frozen_string_literal: true

namespace :import do
  task :tick_lists, %i[database out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    all_old_data = import_db.execute('SELECT * FROM tick_lists').to_a

    # 0 : id
    # 1 : user_id
    # 2 : route_id
    # 3 : created_at
    # 4 : updated_at

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[2]}"

      user = User.find_by legacy_id: data[1]
      crag_route = CragRoute.find_by legacy_id: data[2]

      tick_list = TickList.new(
        user: user,
        crag_route: crag_route,
        created_at: data[3],
        updated_at: data[4]
      )

      binding.pry unless tick_list.save
    end

    out.puts 'End'
  end
end
