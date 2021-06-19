# frozen_string_literal: true

namespace :import do
  task :subscribes, %i[database out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym
    errors = []

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    all_old_data = import_db.execute('SELECT * FROM subscribes').to_a

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[1]}"

      subscribe = Subscribe.new(
        legacy_id: data[0],
        email: data[1],
        error: data[3],
        subscribed_at: data[4],
        created_at: data[4],
        updated_at: data[5]
      )
      errors << "#{data[0]} : #{subscribe.errors.full_messages}" unless subscribe.save
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
