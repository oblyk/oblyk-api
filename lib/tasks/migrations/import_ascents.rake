# frozen_string_literal: true

namespace :import do
  task :ascents, %i[database out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    all_old_data = import_db.execute('SELECT * FROM crosses').to_a
    crosse_sections_data = import_db.execute('SELECT * FROM cross_sections').to_a
    route_sections_data = import_db.execute('SELECT * FROM route_sections ORDER BY route_id, section_order').to_a
    descriptions_data = import_db.execute('SELECT * FROM descriptions WHERE cross_id IS NOT NULL').to_a

    # 0 : id
    # 1 : route_id
    # 2 : user_id
    # 3 : status_id
    # 4 : mode_id
    # 5 : hardness_id
    # 6 : environment
    # 7 : attempt
    # 8 : release_at
    # 9 : created_at
    # 10 : updated_at
    # 11 : min_grade_val
    # 12 : max_grade_val

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[1]}"

      crag_route = CragRoute.find_by legacy_id: data[1]
      user = User.find_by legacy_id: data[2]

      selected_section = []

      crosse_sections_data.each do |cross_section|
        next if cross_section[1] != data[0]

        route_section = nil
        route_sections_data.each do |route_section_data|
          next if route_section_data[0] != cross_section[2]

          route_section = route_section_data
          break
        end

        selected_section.push(route_section[12] - 1)
      end

      old_comment = nil
      descriptions_data.each do |description|
        next if description[6] != data[0]

        old_comment = description
        break
      end

      ascent_status = nil
      ascent_status = 'project' if data[3] == 1
      ascent_status = 'sent' if data[3] == 2
      ascent_status = 'red_point' if data[3] == 3
      ascent_status = 'flash' if data[3] == 4
      ascent_status = 'onsight' if data[3] == 5
      ascent_status = 'repetition' if data[3] == 6

      roping_status = nil
      roping_status = 'lead_climb' if data[4] == 1
      roping_status = 'top_rope' if data[4] == 2
      roping_status = 'multi_pitch_leader' if data[4] == 3
      roping_status = 'multi_pitch_second' if data[4] == 4
      roping_status = 'multi_pitch_alternate_lead' if data[4] == 5

      hardness_status = nil
      hardness_status = 'easy_for_the_grade' if data[5] == 2
      hardness_status = 'this_grade_is_accurate' if data[5] == 3
      hardness_status = 'sandbagged' if data[5] == 4

      note = nil
      private_comment = true
      comment = nil
      if old_comment
        note = if old_comment[5].zero?
                 nil
               else
                 old_comment[5] - 1
               end
        comment = old_comment[3]
        private_comment = old_comment[9]
      end

      ascent_crag_route = AscentCragRoute.new(
        ascent_status: ascent_status,
        roping_status: roping_status,
        attempt: data[7],
        user: user,
        crag_route: crag_route,
        selected_sections: selected_section,
        note: note,
        comment: comment,
        legacy_id: data[0],
        released_at: data[8],
        created_at: data[9],
        updated_at: data[10],
        private_comment: private_comment,
        hardness_status: hardness_status
      )
      binding.pry unless ascent_crag_route.save
    end

    out.puts 'End'
  end

  task :ascent_users, %i[database out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    all_old_data = import_db.execute('SELECT * FROM cross_users').to_a

    # 0 : id
    # 1 : cross_id
    # 2 : user_id
    # 3 : created_at
    # 4 : updated_at

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[2]}"

      user = User.find_by legacy_id: data[2]
      ascent_crag_route = AscentCragRoute.find_by legacy_id: data[1]

      ascent_user = AscentUser.new(
        user: user,
        ascent: ascent_crag_route,
        created_at: data[3],
        updated_at: data[4]
      )

      binding.pry unless ascent_user.save
    end

    out.puts 'End'
  end
end
