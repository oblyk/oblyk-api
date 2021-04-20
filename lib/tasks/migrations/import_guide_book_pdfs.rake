# frozen_string_literal: true

namespace :import do
  task :guide_book_pdfs, %i[database storage_path out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym
    storage_path = args[:storage_path]

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    all_old_data = import_db.execute('SELECT * FROM topo_pdfs').to_a

    # 0 : id
    # 1 : user_id
    # 2 : crag_id
    # 3 : label
    # 4 : description
    # 5 : author
    # 6 : slug_label
    # 7 : created_at
    # 8 : updated_at

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[1]}"

      user = User.find_by legacy_id: data[1]
      crag = Crag.find_by legacy_id: data[2]

      name = data[3].presence || 'sans nom'

      guide_book_pdf = GuideBookPdf.new(
        name: name,
        description: data[4],
        author: data[5],
        publication_year: nil,
        crag: crag,
        user: user,
        legacy_id: data[0],
        created_at: data[7],
        updated_at: data[8]
      )

      pdf_file = File.open("#{storage_path}/topos/PDF/#{data[6]}")
      guide_book_pdf.pdf_file.attach(io: pdf_file, filename: data[6])

      binding.pry unless guide_book_pdf.save
    end

    out.puts 'End'
  end
end
