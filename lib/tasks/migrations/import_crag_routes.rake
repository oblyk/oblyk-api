# frozen_string_literal: true

namespace :import do
  task :crag_routes, %i[database out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym
    errors = []

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    all_old_data = import_db.execute('SELECT * FROM routes').to_a
    route_sections_data = import_db.execute('SELECT * FROM route_sections ORDER BY route_id, section_order').to_a

    # Routes
    # 0 : id
    # 1 : label
    # 2 : crag_id
    # 3 : sector_id
    # 4 : user_id
    # 5 : climb_id
    # 6 : height
    # 7 : open_year
    # 8 : opener
    # 9 : note
    # 10 : nb_note
    # 11 : nb_longueur
    # 12 : views
    # 13 : deleted_at
    # 14 : created_at
    # 15 : updated_at
    # 16 : min_grade_val
    # 17 : max_grade_val

    # Route sections
    # 0 : id
    # 1 : route_id
    # 2 : grade
    # 3 : sub_grade
    # 4 : grade_val
    # 5 : section_height
    # 6 : nb_point
    # 7 : point_id
    # 8 : anchor_id
    # 9 : incline_id
    # 10 : reception_id
    # 11 : start_id
    # 12 : section_order
    # 13 : deleted_at
    # 14 : created_at
    # 15 : updated_at

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[1]}"

      user = User.find_by legacy_id: data[4]
      crag_sector = CragSector.find_by legacy_id: data[3]
      crag = Crag.find_by legacy_id: data[2]

      climbing_type = nil
      climbing_type = 'sport_climbing' if data[5] == 3
      climbing_type = 'bouldering' if data[5] == 2
      climbing_type = 'multi_pitch' if data[5] == 4
      climbing_type = 'trad_climbing' if data[5] == 5
      climbing_type = 'aid_climbing' if data[5] == 6
      climbing_type = 'deep_water' if data[5] == 7
      climbing_type = 'via_ferrata' if data[5] == 8

      sections = []
      bolt_type = nil
      anchor_type = nil
      incline_type = nil
      start_type = nil
      reception_type = nil

      route_sections_data.each do |route_section|
        next if route_section[1] != data[0]

        bolt_type = 'forged_eye_bolts' if route_section[7] == 2
        bolt_type = 'bolt_hangers' if route_section[7] == 3
        bolt_type = 'open_staple_bolts' if route_section[7] == 4
        bolt_type = 'staple_u_bolts' if route_section[7] == 5
        bolt_type = 'no_bolts' if route_section[7] == 6

        anchor_type = 'bolted_anchor_chains' if route_section[8] == 2
        anchor_type = 'bolted_anchor_no_chains' if route_section[8] == 3
        anchor_type = 'pigtail_anchors' if route_section[8] == 4
        anchor_type = 'traditional_anchor' if route_section[8] == 5
        anchor_type = 'no_anchor' if route_section[8] == 6

        incline_type = 'slab' if route_section[9] == 2
        incline_type = 'vertical' if route_section[9] == 3
        incline_type = 'slight_overhang' if route_section[9] == 4
        incline_type = 'overhang' if route_section[9] == 5
        incline_type = 'roof' if route_section[9] == 6

        start_type = 'sit' if route_section[11] == 2
        start_type = 'down' if route_section[11] == 3
        start_type = 'stand' if route_section[11] == 4
        start_type = 'jump' if route_section[11] == 5
        start_type = 'run_and_jump' if route_section[11] == 6

        reception_type = 'good' if route_section[10] == 2
        reception_type = 'correct' if route_section[10] == 3
        reception_type = 'bad' if route_section[10] == 4
        reception_type = 'dangerous' if route_section[10] == 5

        grade = "#{route_section[2]}#{route_section[3]}".strip
        grade = '?' if grade.blank?
        grade = '?' if grade == '??'
        grade = '?' if grade == '???'
        grade = '?' if grade == '?+'
        grade = '8a/b' if grade == '8a/8b+'
        grade = '8a/b' if grade == '8a/8b?'
        grade = '8a/b' if grade == '8a/8b'
        grade = '8b/c' if grade == '8b/8c+'
        grade = '8b/c' if grade == '8b/8c?'
        grade = '7c/8a' if grade == '7c/8a?'
        grade = '7c/8a' if grade == '7c/8a+'
        grade = '6a/A0' if grade == '6a>A0'
        grade = '7a' if grade == '7a/a'
        grade = '7a' if grade == '7a/a'
        grade = '5c/A0' if grade == 'A0 & 5C'
        grade = '5b/c' if grade == '5b/5c'
        grade = '7c' if grade == '7c/c'
        grade = '5c/A0' if grade == '5c/4bA0'
        grade = '6a/A2' if grade == 'A2 6a'
        grade = '6c/5c' if grade == '6c / 5c'
        grade = '6a/A0' if grade == 'A0 puis 6a'
        grade = '6a/A3' if grade == 'A3 6a'
        grade = '9?' if grade == '9z'
        grade = '9?' if grade == '9zz'
        grade = '6a/4c' if grade == '6a/4c/'
        grade = '7a/7c' if grade == '7aA0/7c'
        grade = '5b/6c' if grade == '5b ou 6c'
        grade = '6c/A0' if grade == '6c>A0>'
        grade = '6a/A0' if grade == '6a>A0>'
        grade = '5c/6a' if grade == '5c/6a/'
        grade = '6c/A1' if grade == '6c OU A1'
        grade = '5b/c' if grade == '5b/c/c'
        grade = '6b' if grade == '6b/6b'
        grade = '6b' if grade == '6a/b'
        grade = '7a/b' if grade == '7a/7b'
        grade = '7b/c' if grade == '7b/7c'
        grade = '7b/c' if grade == '7b/7c+'
        grade = '7b/c' if grade == '7b/7c?'
        grade = '7a/b' if grade == '7a/7b?'
        grade = '6b/c' if grade == '6b/6c'
        grade = '6a/b' if grade == '6a/6b'
        grade = '6b/c' if grade == '6b/c/c'
        grade = '5c/A0' if grade == '5c/4bA0/'
        grade = '6a' if grade == '6a/4c///'
        grade = '5a/b' if grade == '5a/b/b'
        grade = '6a/6b' if grade == '6a/6b+'
        grade = '6c/7a' if grade == '6c/7a?'
        grade = '6c/7a' if grade == '6c/7a+'
        grade = '6a/b' if grade == '6a/b/b'
        grade = '6c/A0' if grade == '6c>A0>>>'
        grade = '6c/5c' if grade == '6c / 5c /'
        grade = '6a/A2' if grade == 'A2 6a'
        grade = '6a/A3' if grade == 'A3 6a'
        grade = '7a/A0' if grade == '7a/A0/'
        grade = '5b' if grade == '5vv'
        grade = '6b/+' if grade == '6b/6b/+'
        grade = '6a/b' if grade == '6a/6b+/'
        grade = '5b/5c' if grade == '5b/5c+/'
        grade = '5b/c' if grade == '5b/c/c/c/c'
        grade = '5c/A1' if grade == '5c/A1/'
        grade = '6a+' if grade == '6a +'
        grade = '7a/A0' if grade == '7aA0/7c/'
        grade = '5c/6a' if grade == '5c/6a///'
        grade = '7a/+' if grade == '7a/a/a+'
        grade = '7c/+' if grade == '7c/c/c+'
        grade = '6b/+' if grade == '6b/6b//+'
        grade = '6a/A0' if grade == 'A0 puis 6a puis'
        grade = '5b/6c' if grade == '5b ou 6c ou'
        grade = '6c/A1' if grade == '6c OU A1+ OU'
        grade = '5c/A0' if grade == 'A0 & 5C & C'
        grade = '5c/A0' if grade == '5c/4bA0///'
        grade = '5c/A2' if grade == '5c A2'
        grade = '6b/A1' if grade == '6b A1'
        grade = '6a/A1' if grade == '6a A1'
        grade = '6a/A0' if grade == '6a/A0/'
        grade = '7a/A0' if grade == '7a/A0+/'
        grade = '7a/A1' if grade == '7a/A1/'
        grade = '5c/6a' if grade == '5c/6a/'

        sections << {
          climbing_type: climbing_type,
          description: nil,
          grade: grade,
          grade_value: route_section[4],
          height: (route_section[5] || 0).positive? ? route_section[5] : nil,
          bolt_count: (route_section[6] || 0).positive? ? route_section[6] : nil,
          bolt_type: bolt_type,
          anchor_type: anchor_type,
          incline_type: incline_type,
          start_type: start_type,
          reception_type: reception_type,
          tags: []
        }
      end

      name = data[1].presence || 'sans nom'

      crag_route = CragRoute.new(
        id: data[0],
        name: name,
        height: (data[6] || 0).positive? ? data[6] : nil,
        open_year: data[7],
        opener: data[8],
        sections: sections,
        climbing_type: climbing_type,
        incline_type: incline_type,
        reception_type: reception_type,
        start_type: start_type,
        difficulty_appreciation: nil,
        note: nil,
        note_count: nil,
        ascents_count: nil,
        sections_count: nil,
        max_grade_value: nil,
        min_grade_value: nil,
        max_grade_text: nil,
        min_grade_text: nil,
        max_bolt: nil,
        crag: crag,
        crag_sector: crag_sector,
        user: user,
        legacy_id: data[0],
        created_at: data[14],
        updated_at: data[15],
        deleted_at: data[13],
        photo_id: nil,
        slug_name: nil,
        comments_count: nil,
        videos_count: nil,
        photos_count: nil,
        location: nil,
        votes: nil
      )

      errors << "#{crag_route.legacy_id} : #{crag_route.errors.full_messages}" unless crag_route.save
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
