# frozen_string_literal: true

namespace :disc_charts do
  desc 'Generate disc chart PDF from a tab-separated CSV file (Oblyk export format)'
  task :from_csv, %i[csv_file] => :environment do |_t, args|
    require 'rqrcode'
    require 'csv'

    csv_path = File.expand_path(args[:csv_file])
    unless File.exist?(csv_path)
      warn "File not found: #{csv_path}"
      raise
    end

    rows = CSV.read(csv_path, col_sep: "\t", headers: true)

    routes = rows.map do |row|
      colors = row['hold_colors'].split(/,\s*/)
      openers = row['openers'].split(/,\s*/).map { |name| { name: name.strip } }
      short_url = row['short_url']
      qr_svg = RQRCode::QRCode.new(short_url, level: :l).as_svg(viewbox: true, use_path: true)

      {
        anchor_number: row['anchor'].to_i,
        hold_colors: colors,
        grade_to_s: row['grade'],
        openers: openers,
        qr_svg: qr_svg
      }
    end

    routes.sort_by! { |r| r[:anchor_number] }

    pdf_io = DiscChartService.new(routes).generate_pdf

    basename = File.basename(csv_path, File.extname(csv_path))
    output_path = "/tmp/#{basename}.pdf"
    File.binwrite(output_path, pdf_io.string)
    puts "PDF written to #{output_path} (#{File.size(output_path)} bytes)"
    puts "#{routes.size} routes across #{routes.map { |r| r[:anchor_number] }.uniq.size} anchors"
  end

  desc 'Generate disc chart PDF for a gym space (routes fetched from the database)'
  task :from_space, %i[gym_space_id] => :environment do |_t, args|
    require 'rqrcode'

    space = GymSpace.find(args[:gym_space_id])
    gym_routes = space.gym_routes.includes(:gym_openers).where(dismounted_at: nil).order(:anchor_number)

    if gym_routes.empty?
      warn "No active routes found for GymSpace ##{space.id} (#{space.name})"
      raise
    end

    routes = gym_routes.map do |r|
      qr_svg = RQRCode::QRCode.new(r.short_app_path, level: :l).as_svg(viewbox: true, use_path: true)
      {
        anchor_number: r.anchor_number,
        hold_colors: r.hold_colors,
        grade_to_s: r.grade_to_s,
        openers: r.gym_openers.map { |o| { name: o.name } },
        qr_svg: qr_svg
      }
    end

    pdf_io = DiscChartService.new(routes).generate_pdf

    slug = space.name.parameterize
    output_path = "/tmp/disc_charts_#{slug}.pdf"
    File.binwrite(output_path, pdf_io.string)
    puts "PDF written to #{output_path} (#{File.size(output_path)} bytes)"
    puts "#{routes.size} routes across #{routes.map { |r| r[:anchor_number] }.uniq.size} anchors"
    puts "Gym space: #{space.name} (ID: #{space.id})"
  end
end
