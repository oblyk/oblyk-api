# frozen_string_literal: true

namespace :import do
  task :words, %i[database out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    all_old_data = import_db.execute('SELECT * FROM words').to_a

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[1]}"

      user = User.find_by legacy_id: data[3]

      word = Word.new(
        legacy_id: data[0],
        user: user,
        name: data[1],
        definition: data[2],
        created_at: data[4],
        updated_at: data[5]
      )
      binding.pry unless word.save
    end

    out.puts 'End'
  end
end
