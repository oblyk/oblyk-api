# frozen_string_literal: true

namespace :import do
  desc 'Import words data'
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
      Word.create legacy_id: data[0], name: data[1], definition: data[2]
    end

    out.puts 'End'
  end
end
