# frozen_string_literal: true

namespace :import do
  task :users, %i[database storage_path out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym
    storage_path = args[:storage_path]

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    all_old_data = import_db.execute('SELECT * FROM users').to_a

    partner_settings_data = import_db.execute('SELECT * FROM user_partner_settings').to_a
    user_places_data = import_db.execute('SELECT * FROM user_places').to_a
    user_settings_data = import_db.execute('SELECT * FROM user_settings').to_a

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[1]}"

      # Date of birth
      old_birth = data[5]
      date_of_birth = nil
      date_of_birth = "#{old_birth}-01-01" if old_birth.present? && old_birth > 1900 && old_birth < 2021

      # Genre
      genre = nil
      genre = 'male' if data[6] == 2
      genre = 'female' if data[6] == 1

      # Partner settings
      partner_setting = []
      partner_settings_data.each do |partner_setting_data|
        if partner_setting_data[1] == data[0]
          partner_setting = partner_setting_data
          break
        end
      end

      # description
      description = data[7].presence
      description = partner_setting[3] if description.blank? && partner_setting[3].present?

      # min and max grade
      max_grade = nil
      max_grade = Grade.to_value(partner_setting[12]) if partner_setting[12] != '2a'
      min_grade = nil
      min_grade = Grade.to_value(partner_setting[13]) if partner_setting[13] != '2a'

      # Partner places
      user_place = []
      user_places_data.each do |user_place_data|
        next if user_place_data[3] > 180
        next if user_place_data[1] == 2058

        next unless user_place_data[1] == data[0] && user_place_data[7] == 1

        user_place = user_place_data
        if user_place_data[1] == 2728
          user_place[2] = -22.269713
          user_place[3] = 166.468318
        end
        break
      end

      # User setting
      user_setting = []
      user_settings_data.each do |user_setting_data|
        if user_setting_data[1] == data[0]
          user_setting = user_setting_data
          break
        end
      end

      user = User.new(
        legacy_id: data[0],
        first_name: data[1],
        last_name: nil,
        email: data[2],
        password_digest: data[3],
        date_of_birth: date_of_birth,
        genre: genre,
        description: description,
        partner_search: partner_setting[2] == 1 ? true : nil,
        newsletter_accepted_at: nil,
        latitude: nil,
        longitude: nil,
        bouldering: partner_setting[4] == 1 ? true : nil,
        sport_climbing: partner_setting[5] == 1 ? true : nil,
        multi_pitch: partner_setting[6] == 1 ? true : nil,
        trad_climbing: partner_setting[7] == 1 ? true : nil,
        aid_climbing: partner_setting[8] == 1 ? true : nil,
        deep_water: partner_setting[9] == 1 ? true : nil,
        via_ferrata: partner_setting[10] == 1 ? true : nil,
        pan: partner_setting[11] == 1 ? true : nil,
        grade_max: max_grade,
        grade_min: min_grade,
        created_at: data[11],
        updated_at: data[12],
        deleted_at: data[10],
        slug_name: nil,
        localization: nil,
        language: nil,
        reset_password_token: nil,
        reset_password_token_expired_at: nil,
        follows_count: nil,
        public_profile: user_setting[5],
        public_outdoor_ascents: nil,
        public_indoor_ascents: nil,
        partner_latitude: user_place[2],
        partner_longitude: user_place[3],
        last_activity_at: data[12] || data[11],
        partner_search_activated_at: user_place[9]
      )

      if user.save
        # Import avatar
        if File.exist?("#{storage_path}/users/1000/user-#{user.legacy_id}.jpg")
          avatar = File.open("#{storage_path}/users/1000/user-#{user.legacy_id}.jpg")
          user.avatar.attach(io: avatar, filename: "avatar-#{data[3]}.jpg")
        end

        # Import banner
        if File.exist?("#{storage_path}/users/1300/bandeau-#{user.legacy_id}.jpg")
          avatar = File.open("#{storage_path}/users/1300/bandeau-#{user.legacy_id}.jpg")
          user.banner.attach(io: avatar, filename: "banner-#{data[3]}.jpg")
        end
      else
        binding.pry
      end
    end

    out.puts 'End'
  end
end
