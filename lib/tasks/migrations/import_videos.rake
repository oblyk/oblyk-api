# frozen_string_literal: true

namespace :import do
  task :videos, %i[database out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    all_old_data = import_db.execute('SELECT * FROM videos').to_a

    # 0 : id
    # 1 : user_id
    # 2 : viewable_id
    # 3 : viewable_type
    # 4 : iframe
    # 5 : description
    # 6 : created_at
    # 7 : updated_at

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[4]}"

      user = User.find_by legacy_id: data[1]

      # App\Crag
      # App\Route
      # App\Gym

      viewable_type = nil
      viewable = nil
      if data[3] == 'App\Crag'
        viewable_type = 'Crag'
        viewable = Crag.find_by legacy_id: data[2]
      end

      if data[3] == 'App\Route'
        viewable_type = 'CragRoute'
        viewable = CragRoute.find_by legacy_id: data[2]
      end

      if data[3] == 'App\Gym'
        viewable_type = 'Gym'
        viewable = Gym.find_by legacy_id: data[2]
      end

      next if viewable.blank?

      video = Video.new(
        description: data[5],
        url: data[4],
        user: user,
        viewable_type: viewable_type,
        viewable_id: viewable.id,
        legacy_id: data[0],
        created_at: data[6],
        updated_at: data[7]
      )
      binding.pry unless video.save
    end

    out.puts 'End'
  end
end
