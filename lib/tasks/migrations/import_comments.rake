# frozen_string_literal: true

namespace :import do
  task :comments, %i[database out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    all_old_data = import_db.execute('SELECT * FROM descriptions WHERE cross_id IS NULL').to_a

    # 0 : id
    # 1 : descriptive_id
    # 2 : descriptive_type
    # 3 : description
    # 4 : user_id
    # 5 : note
    # 6 : cross_id
    # 7 : created_at
    # 8 : updated_at
    # 8 : private

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[4]}"

      user = User.find_by legacy_id: data[4]

      # descriptive_type
      # App\Crag
      # App\Sector
      # App\Route
      # App\Topo
      # App\Massive
      # App\Gym
      # App\GymRoute

      next if data[3].blank?

      commentable_type = nil
      commentable = nil
      if data[2] == 'App\Crag'
        commentable_type = 'Crag'
        commentable = Crag.find_by legacy_id: data[1]
      end

      if data[2] == 'App\Sector'
        commentable_type = 'CragSector'
        commentable = CragSector.find_by legacy_id: data[1]
      end

      if data[2] == 'App\Route'
        commentable_type = 'CragRoute'
        commentable = CragRoute.find_by legacy_id: data[1]
      end

      if data[2] == 'App\Topo'
        commentable_type = 'GuideBookPaper'
        commentable = GuideBookPaper.find_by legacy_id: data[1]
      end

      if data[2] == 'App\Massive'
        commentable_type = 'Area'
        commentable = Area.find_by legacy_id: data[1]
      end

      if data[2] == 'App\Gym'
        commentable_type = 'Gym'
        commentable = Gym.find_by legacy_id: data[1]
      end

      if data[2] == 'App\GymRoute'
        commentable_type = 'GymRoute'
        commentable = GymRoute.find_by legacy_id: data[1]
      end

      next if commentable.blank?

      comment = Comment.new(
        body: data[3],
        commentable_type: commentable_type,
        commentable_id: commentable.id,
        user: user,
        legacy_id: data[0],
        created_at: data[7],
        updated_at: data[8]
      )
      binding.pry unless comment.save
    end

    out.puts 'End'
  end
end
