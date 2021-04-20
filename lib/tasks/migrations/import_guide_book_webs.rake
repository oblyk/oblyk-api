# frozen_string_literal: true

namespace :import do
  task :guide_book_webs, %i[database out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    all_old_data = import_db.execute('SELECT * FROM topo_webs').to_a

    # 0 : id
    # 1 : user_id
    # 2 : crag_id
    # 3 : label
    # 4 : url
    # 5 : created_at
    # 6 : updated_at

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[1]}"

      user = User.find_by legacy_id: data[1]
      crag = Crag.find_by legacy_id: data[2]

      guide_book_web = GuideBookWeb.new(
        name: data[3],
        url: data[4],
        publication_year: nil,
        user: user,
        crag: crag,
        legacy_id: data[0],
        created_at: data[5],
        updated_at: data[6]
      )

      binding.pry unless guide_book_web.save
    end

    out.puts 'End'
  end
end
