# frozen_string_literal: true

require 'open-uri'

namespace :import do
  task :photos, %i[database storage_path out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym
    storage_path = args[:storage_path]
    errors = []

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    all_old_data = import_db.execute('SELECT * FROM photos').to_a

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[1]}"

      type = nil
      illustrable_id = nil

      if data[2] == 'App\Crag'
        type = 'Crag'
        illustrable_id = Crag.find_by(legacy_id: data[1]).id
      end

      if data[2] == 'App\Route'
        type = 'CragRoute'
        illustrable_id = CragRoute.find_by(legacy_id: data[1]).id
      end

      if data[2] == 'App\Sector'
        type = 'CragSector'
        illustrable_id = CragSector.find_by(legacy_id: data[1]).id
      end

      photo = Photo.new(
        legacy_id: data[0],
        description: data[6],
        exif_model: data[9],
        exif_make: data[10],
        source: data[11],
        alt: nil,
        user: User.find_by(legacy_id: data[4]),
        copyright_by: data[12],
        copyright_nc: data[13],
        copyright_nd: data[14],
        illustrable_type: type,
        illustrable_id: illustrable_id,
        created_at: data[7],
        updated_at: data[8]
      )

      picture = File.open("#{storage_path}/photos/crags/1300/#{data[3]}")
      photo.picture.attach(io: picture, filename: data[3])

      errors << "#{data[0]} : #{photo.errors.full_messages}" unless photo.save
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
