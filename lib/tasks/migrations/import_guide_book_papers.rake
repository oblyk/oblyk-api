# frozen_string_literal: true

namespace :import do
  task :guide_book_papers, %i[database storage_path out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym
    storage_path = args[:storage_path]
    errors = []

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    all_old_data = import_db.execute('SELECT * FROM topos').to_a

    # 0 : id
    # 1 : user_id
    # 2 : label
    # 3 : author
    # 4 : editor
    # 5 : editionYear
    # 6 : price
    # 7 : page
    # 8 : weight
    # 9 : views
    # 10 : created_at
    # 11 : updated_at
    # 12 : ean
    # 13 : vc_ref

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[1]}"

      user = User.find_by legacy_id: data[1]

      name = data[2].presence || 'sans nom'

      price_cents = nil
      price_cents = data[6] * 100 if (data[6] || 0).positive?

      guide_book_paper = GuideBookPaper.new(
        name: name,
        author: data[3],
        editor: data[4],
        publication_year: data[5],
        price_cents: price_cents,
        ean: data[12],
        vc_reference: data[13],
        number_of_page: (data[7] || 0).positive? ? data[7] : nil,
        weight: (data[8] || 0).positive? ? data[8] : nil,
        user: user,
        legacy_id: data[0],
        created_at: data[10],
        updated_at: data[11]
      )

      if guide_book_paper.save
        # Import cover
        if File.exist?("#{storage_path}/topos/700/topo-#{guide_book_paper.legacy_id}.jpg")
          cover = File.open("#{storage_path}/topos/700/topo-#{guide_book_paper.legacy_id}.jpg")
          guide_book_paper.cover.attach(io: cover, filename: "cover-#{data[3]}.jpg")
        end
      else
        errors << "#{data[0]} : #{guide_book_paper.errors.full_messages}"
      end
    end

    out.puts ''
    out.puts 'Errors list :'
    errors.each do |error|
      out.puts error
    end

    out.puts ''
    out.puts 'end'
  end

  task :guide_book_paper_crags, %i[database out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym
    errors = []

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    all_old_data = import_db.execute('SELECT * FROM topo_crags').to_a

    # 0 : id
    # 1 : user_id
    # 2 : topo_id
    # 3 : crag_id
    # 4 : created_at
    # 5 : updated_at

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[2]}"

      user = User.find_by legacy_id: data[1]
      guide_book_paper = GuideBookPaper.find_by legacy_id: data[2]
      crag = Crag.find_by legacy_id: data[3]

      next if GuideBookPaperCrag.where(crag: crag, guide_book_paper: guide_book_paper).exists?

      guide_book_paper_crag = GuideBookPaperCrag.new(
        crag: crag,
        guide_book_paper: guide_book_paper,
        user: user,
        created_at: data[4],
        updated_at: data[5]
      )

      errors << "#{data[0]} : #{guide_book_paper_crag.errors.full_messages}" unless guide_book_paper_crag.save
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
