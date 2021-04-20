# frozen_string_literal: true

namespace :import do
  task :gym_grades, %i[database out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    all_old_data = import_db.execute('SELECT * FROM gym_grades').to_a

    # 0 : id
    # 1 : gym_id
    # 2 : label
    # 3 : created_at
    # 4 : updated_at
    # 5 : difficulty_is_tag_color
    # 6 : difficulty_is_hold_color
    # 7 : has_hold_color
    # 8 : difficulty_system

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[2]}"

      gym = Gym.find_by legacy_id: data[1]

      difficulty_system = 'hold_color'
      difficulty_system = 'hold_color' if data[8].zero?
      difficulty_system = 'tag_color' if data[8] == 1
      difficulty_system = 'grade' if data[8] == 3
      difficulty_system = 'pan' if data[8] == 4

      gym_grade = GymGrade.new(
        name: data[2],
        difficulty_system: difficulty_system,
        has_hold_color: data[7],
        gym: gym,
        legacy_id: data[0],
        created_at: data[3],
        updated_at: data[4],
        use_grade_system: true,
        use_point_system: false,
        use_point_division_system: false
      )

      binding.pry unless gym_grade.save
    end

    out.puts 'End'
  end

  task :gym_grade_lines, %i[database out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    all_old_data = import_db.execute('SELECT * FROM gym_grade_lines').to_a

    # 0 : id
    # 1 : gym_grade_id
    # 2 : label
    # 3 : color
    # 4 : grade_val
    # 5 : order
    # 6 : created_at
    # 7 : updated_at

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[2]}"

      gym_grade = GymGrade.find_by legacy_id: data[1]

      gym_grade_line = GymGradeLine.new(
        name: data[2],
        colors: [data[3]],
        order: data[5],
        grade_text: Grade.level(data[4]),
        grade_value: data[4],
        gym_grade: gym_grade,
        legacy_id: data[0],
        created_at: data[6],
        updated_at: data[7]
      )

      binding.pry unless gym_grade_line.save
    end

    out.puts 'End'
  end
end
