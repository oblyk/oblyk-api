# frozen_string_literal: true

namespace :import do
  task :alerts, %i[database out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym
    errors = []

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    all_old_data = import_db.execute('SELECT * FROM exceptions').to_a

    # 0 : id
    # 1 : crag_id
    # 2 : user_id
    # 3 : exception_type
    # 4 : description
    # 5 : created_at
    # 6 : updated_at

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[1]}"

      user = User.find_by legacy_id: data[2]
      crag = Crag.find_by legacy_id: data[1]

      alert_type = nil
      alert_type = 'good' if data[3] == '4'
      alert_type = 'bad' if data[3] == '1'

      alert = Alert.new(
        description: data[4],
        alert_type: alert_type,
        user: user,
        alertable_type: 'Crag',
        alertable_id: crag.id,
        alerted_at: data[5],
        created_at: data[5],
        updated_at: data[6]
      )

      errors << "#{data[0]} : #{alert.errors.full_messages}" unless alert.save
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
