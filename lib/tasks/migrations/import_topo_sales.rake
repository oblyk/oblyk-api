# frozen_string_literal: true

namespace :import do
  task :place_of_sales, %i[database out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    all_old_data = import_db.execute('SELECT * FROM topo_sales').to_a

    # 0 : id
    # 1 : user_id
    # 2 : topo_id
    # 3 : label
    # 4 : description
    # 5 : url
    # 6 : lat
    # 7 : lng
    # 8 : created_at
    # 9 : updated_at

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[1]}"

      user = User.find_by legacy_id: data[1]
      guide_book_paper = GuideBookPaper.find_by legacy_id: data[2]

      latitude = data[6] != 0 ? data[6] : nil
      longitude = data[7] != 0 ? data[7] : nil

      place_of_sale = PlaceOfSale.new(
        name: data[3],
        url: data[5],
        description: data[4],
        latitude: latitude,
        longitude: longitude,
        code_country: nil,
        country: nil,
        postal_code: nil,
        city: nil,
        region: nil,
        address: nil,
        guide_book_paper: guide_book_paper,
        user: user,
        created_at: data[8],
        updated_at: data[9]
      )

      binding.pry unless place_of_sale.save
    end

    out.puts 'End'
  end
end
