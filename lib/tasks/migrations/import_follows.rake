# frozen_string_literal: true

namespace :import do
  task :follows, %i[database out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym
    errors = []

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    all_old_data = import_db.execute('SELECT * FROM follows').to_a

    # 0 : id
    # 1 : followed_id
    # 2 : followed_type
    # 3 : user_id
    # 4 : created_at
    # 5 : updated_at

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[2]} -> #{data[1]}"

      user = User.find_by legacy_id: data[3]

      # App\Crag
      # App\Topo
      # App\Gym
      # App\User

      followable_type = nil
      followable = nil
      accepted_at = nil
      if data[2] == 'App\Crag'
        followable_type = 'Crag'
        followable = Crag.find_by legacy_id: data[1]
        accepted_at = data[4]
      end

      if data[2] == 'App\Topo'
        followable_type = 'GuideBookPaper'
        followable = GuideBookPaper.find_by legacy_id: data[1]
        accepted_at = data[4]
      end

      if data[2] == 'App\Gym'
        followable_type = 'Gym'
        followable = Gym.find_by legacy_id: data[1]
        accepted_at = data[4]
      end

      if data[2] == 'App\User'
        followable_type = 'User'
        followable = User.find_by legacy_id: data[1]
        all_old_data.each do |followed_in_return|
          next if followed_in_return[2] != 'App\User' && followed_in_return[1] != user.legacy_id

          accepted_at = followed_in_return[4]
          break
        end
      end

      next if followable.blank?

      follow = Follow.new(
        followable_type: followable_type,
        followable_id: followable.id,
        user: user,
        accepted_at: accepted_at,
        legacy_id: data[0],
        created_at: data[4],
        updated_at: data[5]
      )
      errors << "#{data[0]} : #{follow.errors.full_messages}" unless follow.save
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
