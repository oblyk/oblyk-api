# frozen_string_literal: true

namespace :import do
  task :links, %i[database out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym
    errors = []

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    all_old_data = import_db.execute('SELECT * FROM links').to_a

    # 0 : id
    # 1 : linkable_id
    # 2 : linkable_type
    # 3 : label
    # 4 : link
    # 5 : user_id
    # 6 : description
    # 7 : created_at
    # 8 : updated_at

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[4]}"

      user = User.find_by legacy_id: data[5]

      # App\Crag
      # App\Topo
      # App\Massive

      linkable_type = nil
      linkable = nil
      if data[2] == 'App\Crag'
        linkable_type = 'Crag'
        linkable = Crag.find_by legacy_id: data[1]
      end

      if data[2] == 'App\Topo'
        linkable_type = 'GuideBookPaper'
        linkable = GuideBookPaper.find_by legacy_id: data[1]
      end

      if data[2] == 'App\Massive'
        linkable_type = 'Area'
        linkable = Area.find_by legacy_id: data[1]
      end

      next if linkable.blank?

      link = Link.new(
        name: data[3],
        url: data[4],
        description: data[6],
        linkable_type: linkable_type,
        linkable_id: linkable.id,
        user: user,
        legacy_id: data[0],
        created_at: data[7],
        updated_at: data[8]
      )
      errors << "#{data[0]} : #{link.errors.full_messages}" unless link.save
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
