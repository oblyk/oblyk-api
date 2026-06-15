# frozen_string_literal: true

# Generates A4 PDFs containing one circular disc per anchor (relay), where each
# slice represents one climbing route. Inspired by the Python tool at
# https://github.com/hleroy/climbing_route_chart but rewritten in Ruby to
# receive data directly from the Rails database.
#
# Each disc displays:
# - Colored pie slices (solid or gradient) matching the hold colors
# - Grade label and setter name(s) per slice
# - An optional QR code per slice linking to the route page
# - A white center circle and a relay number box at the top
#
# Layout adapts automatically to the number of routes per anchor (1–6).
# For 1 route the disc is a full circle; for 2–6 routes, equal pie slices are
# drawn starting at 12 o'clock (270°). Font sizes, QR sizes, and radial
# distances are configured per route count in the LAYOUT constant.
#
# == Usage
#
#   DiscChartService.new(routes, params = {}).generate_pdf  # => StringIO (PDF bytes)
#
# == Input
#
# +routes+ is an Array of Hashes with the following keys:
#
#   :sheet_reference  Integer        Groups routes onto the same disc (e.g. 1, 2, 3)
#   :hold_colors    Array<String>  Hex color strings. One color = solid fill;
#                                  two or more = linear gradient.
#                                  Examples: ["#ff0000"] or ["#ff0000", "#0000ff"]
#   :grade_to_s     String         Formatted grade label, e.g. "6b+"
#   :openers        Array<Hash>    Route setters. Each hash must have a :name key.
#                                  Example: [{ name: "Alice" }, { name: "Bob" }]
#   :qr_svg         String         Optional. SVG string for the route's QR code.
#                                  Typically produced by:
#                                    RQRCode::QRCode.new(url, level: :l)
#                                                    .as_svg(viewbox: true, use_path: true)
#                                  When present, the QR code is embedded inside the slice.
#
# == Optional params
#
#   :radius    Float  Disc radius in SVG user units (default: 69.5)
#   :title_fs  Float  Title font size (default: 14)
#   :grade_fs  Float  Grade font size (default: 18)
#   :setter_fs Float  Setter name font size (default: 8)
#
# == Example
#
#   routes = gym_routes.map do |r|
#     {
#       sheet_reference: r.sheet_reference,
#       hold_colors:   r.hold_colors,
#       grade_to_s:    r.grade_to_s,
#       openers:       r.openers.map { |o| { name: o.name } },
#       qr_svg:        RQRCode::QRCode.new(r.short_app_path, level: :l)
#                                      .as_svg(viewbox: true, use_path: true)
#     }
#   end
#   pdf_io = DiscChartService.new(routes).generate_pdf
#   send_data pdf_io.read, filename: 'route_labels.pdf', type: 'application/pdf'

class DiscChartService
  TITLE_FS       = 14
  GRADE_FS       = 18
  SETTER_FS      = 8
  RADIUS         = 69.5
  CENTER_X       = 105.0
  CENTER_Y       = 150.0
  QR_SIZE_SINGLE = 35 # QR side length (mm) for a single-route disc

  # Radial layout configs per route count — distances are fractions of RADIUS
  # along each slice's bisector, measured from center.
  # text_d: radial distance for the text anchor point (grade + setter stacked vertically)
  # qr_d:   radial distance for the QR code center
  # offset: starting angle offset (degrees) chosen so no bisector hits 270° (relay box)
  LAYOUT = {
    2 => { text_d: 0.78, qr_d: 0.45, grade_fs: 18, setter_fs: 10, qr_size: 28, grade_gap: 8, setter_gap: 14, offset: 90.0 },
    3 => { text_d: 0.83, qr_d: 0.55, grade_fs: 14, setter_fs: 8,  qr_size: 25, grade_gap: 6, setter_gap: 11, offset: 270.0 },
    4 => { text_d: 0.83, qr_d: 0.60, grade_fs: 13, setter_fs: 7,  qr_size: 22, grade_gap: 5, setter_gap: 10, offset: 270.0 },
    5 => { text_d: 0.83, qr_d: 0.62, grade_fs: 11, setter_fs: 6,  qr_size: 20, grade_gap: 3, setter_gap: 8,  offset: 270.0 },
    6 => { text_d: 0.85, qr_d: 0.62, grade_fs: 10, setter_fs: 5,  qr_size: 18, grade_gap: 2, setter_gap: 6,  offset: 270.0 }
  }.freeze

  def initialize(routes, params = {})
    @routes    = routes
    @radius    = params[:radius]    || RADIUS
    @title_fs  = params[:title_fs]  || TITLE_FS
    @grade_fs  = params[:grade_fs]  || GRADE_FS
    @setter_fs = params[:setter_fs] || SETTER_FS
  end

  def generate_pdf
    grouped  = @routes.group_by { |r| r[:sheet_reference] }
    svg_list = grouped.map { |relay, group| generate_svg_for_relay(relay, group) }
    assemble_pdf(svg_list)
  end

  private

  # --- Color helpers ----

  def dark_color?(hex)
    r = hex[1..2].to_i(16)
    g = hex[3..4].to_i(16)
    b = hex[5..6].to_i(16)
    (0.299 * r + 0.587 * g + 0.114 * b) / 255.0 < 0.5
  end

  def linear_interpolation(start_value, end_value, ratio)
    (start_value + (end_value - start_value) * ratio).round
  end

  def interpolate_middle_color(colors)
    return colors[0] if colors.length == 1

    n   = colors.length - 1
    seg = [(0.5 / (1.0 / n)).to_i, n - 1].min
    t   = (0.5 - seg * (1.0 / n)) / (1.0 / n)
    c1  = colors[seg]
    c2  = colors[seg + 1]
    r   = linear_interpolation(c1[1..2].to_i(16), c2[1..2].to_i(16), t)
    g   = linear_interpolation(c1[3..4].to_i(16), c2[3..4].to_i(16), t)
    b   = linear_interpolation(c1[5..6].to_i(16), c2[5..6].to_i(16), t)
    format('#%02x%02x%02x', r, g, b)
  end

  def text_color_for(hold_colors)
    ref = hold_colors.length > 1 ? interpolate_middle_color(hold_colors) : hold_colors[0]
    dark_color?(ref) ? 'white' : 'black'
  end

  # --- QR code embedding ----

  # Wraps an SVG string (e.g. from rqrcode's +as_svg+) into a nested <svg>
  # element positioned at (+x+, +y+) with the given +size+ (square).
  # A white backing rect is drawn first so the QR is always legible regardless
  # of the slice fill color (including white slices).
  def qr_nested_svg(qr_svg, x, y, size)
    viewbox = qr_svg.match(/viewBox="([^"]+)"/i)&.captures&.first || '0 0 580 580'
    inner   = qr_svg.sub(/<svg[^>]*>/m, '').sub(%r{</svg>\s*\z}m, '').strip
    rx = x.round(2)
    ry = y.round(2)
    <<~XML
      <rect x="#{rx}" y="#{ry}" width="#{size}" height="#{size}" fill="white" stroke="black" stroke-width="0.5"/>
      <svg x="#{rx}" y="#{ry}" width="#{size}" height="#{size}" viewBox="#{viewbox}">
        #{inner}
      </svg>
    XML
  end

  # --- Opener formatting ----

  def openers_to_s(openers)
    names = openers.map { |o| o[:name] }
    return '' if names.empty?
    return names[0] if names.length == 1

    "#{names[0..-2].join(', ')} / #{names[-1]}"
  end

  # --- SVG fill / gradient helpers ----

  # Returns a <linearGradient> XML fragment, or "" for solid colors.
  def gradient_def(id, x1, y1, x2, y2, colors)
    return '' if colors.length == 1

    stops = colors.each_with_index.map do |color, idx|
      offset = colors.length == 1 ? '0%' : "#{(idx * 100.0 / (colors.length - 1)).round}%"
      %(<stop offset="#{offset}" stop-color="#{color}"/>)
    end.join("\n      ")

    <<~XML
      <linearGradient id="#{id}" x1="#{x1}" y1="#{y1}" x2="#{x2}" y2="#{y2}" gradientUnits="userSpaceOnUse">
        #{stops}
      </linearGradient>
    XML
  end

  # Returns the fill="..." attribute string (with surrounding space).
  def fill_attr(id, colors)
    colors.length > 1 ? %( fill="url(##{id})") : %( fill="#{colors[0]}")
  end

  # --- Relay number box ----

  def relay_box_svg(relay)
    cx          = CENTER_X
    cy          = CENTER_Y
    relay_text  = relay.to_s
    font_size   = 14
    rect_width  = relay_text.length * 12 + 8 # 4 px padding each side at ~12px/char
    rect_height = 18
    rect_x      = cx - rect_width / 2.0
    rect_y      = cy - @radius + 4
    # Baseline at ~78% of box height vertically centres capital letters.
    label_y     = rect_y + rect_height * 0.78

    <<~XML
      <rect x="#{rect_x}" y="#{rect_y}" width="#{rect_width}" height="#{rect_height}"
            fill="white" stroke="black" stroke-width="1"/>
      <text x="#{cx}" y="#{label_y.round(2)}" font-size="#{font_size}" text-anchor="middle"
            font-family="DejaVu Sans, sans-serif">#{relay_text}</text>
    XML
  end

  # -- Single-route disc ----

  def render_single_route(relay, route)
    cx           = CENTER_X
    cy           = CENTER_Y
    hold_colors  = route[:hold_colors]
    grad_id      = "grad_#{relay}_0"
    grad         = gradient_def(grad_id, cx - @radius, cy, cx + @radius, cy, hold_colors)
    fill         = fill_attr(grad_id, hold_colors)
    text_color   = text_color_for(hold_colors)
    grade_y      = cy - @radius / 2.0
    setter_y     = grade_y + @grade_fs * 0.7
    grade_to_s   = route[:grade_to_s]
    openers      = openers_to_s(route[:openers])

    circle = <<~XML
      <circle cx="#{cx}" cy="#{cy}" r="#{@radius}"#{fill}
              stroke="black" stroke-width="1"/>
    XML

    grade_y  = cy - @radius + 44
    setter_fs = 10
    texts = <<~XML
      <text x="#{cx}" y="#{grade_y}" font-size="#{@grade_fs}" text-anchor="middle" dominant-baseline="central"
            fill="#{text_color}" font-family="DejaVu Sans, sans-serif">#{grade_to_s}</text>
      <text x="#{cx}" y="#{setter_y}" font-size="#{setter_fs}" text-anchor="middle" dominant-baseline="central"
            fill="#{text_color}" font-family="DejaVu Sans, sans-serif">#{openers}</text>
    XML

    qr_element = ''
    if route[:qr_svg]
      qr_size    = QR_SIZE_SINGLE
      qr_x       = cx - qr_size / 2.0
      qr_y       = cy + @radius * 0.25
      qr_element = qr_nested_svg(route[:qr_svg], qr_x, qr_y, qr_size)
    end

    { defs: grad, body: circle + texts + qr_element }
  end

  # --- Multi-route disc ----

  def render_multi_route(relay, group)
    cx = CENTER_X
    cy = CENTER_Y
    n = group.length
    cfg = DiscChartService::LAYOUT[[n, 6].min]
    sweep = 360.0 / n
    # Per-N offset so no bisector points at 270° (relay box at top of disc)
    offset = cfg[:offset]
    defs = []
    body = []

    group.each_with_index do |route, i|
      start_angle = offset + i * sweep
      end_angle   = start_angle + sweep
      mid_angle   = start_angle + sweep / 2.0
      mid_rad     = mid_angle * Math::PI / 180.0

      # Arc endpoints
      x1 = cx + @radius * Math.cos(start_angle * Math::PI / 180)
      y1 = cy + @radius * Math.sin(start_angle * Math::PI / 180)
      x2 = cx + @radius * Math.cos(end_angle * Math::PI / 180)
      y2 = cy + @radius * Math.sin(end_angle * Math::PI / 180)
      large_arc = sweep > 180 ? 1 : 0

      # Gradient
      grad_id = "grad_#{relay}_#{i}"
      grad = gradient_def(grad_id, x1, y1, x2, y2, route[:hold_colors])
      defs << grad

      # Pie wedge
      path = <<~XML
        <path d="M #{cx} #{cy} L #{x1.round(2)} #{y1.round(2)} A #{@radius} #{@radius} 0 #{large_arc} 1 #{x2.round(2)} #{y2.round(2)} Z"
              #{fill_attr(grad_id, route[:hold_colors])} stroke="black" stroke-width="1"/>
      XML

      text_color = text_color_for(route[:hold_colors])

      # Text anchor point along bisector, then stack grade above / setter below
      anchor_x = (cx + cfg[:text_d] * @radius * Math.cos(mid_rad)).round(2)
      anchor_y = (cy + cfg[:text_d] * @radius * Math.sin(mid_rad)).round(2)
      half_gap = cfg[:grade_fs] * 0.4
      grade_y = (anchor_y - half_gap).round(2)
      setter_y = (anchor_y + half_gap).round(2)

      # QR code — mid-zone along bisector
      qr_element = ''
      texts = ''
      if route[:qr_svg]
        qr_cx = cx + cfg[:qr_d] * @radius * Math.cos(mid_rad)
        qr_cy = cy + cfg[:qr_d] * @radius * Math.sin(mid_rad)
        qr_element = qr_nested_svg(route[:qr_svg], qr_cx - cfg[:qr_size] / 2.0, qr_cy - cfg[:qr_size] / 2.0, cfg[:qr_size])

        grade_x = qr_cx.round(2)
        grade_y = (qr_cy - cfg[:qr_size] / 2.0 - cfg[:grade_gap]).round(2)
        setter_x = qr_cx.round(2)
        setter_y = (qr_cy + cfg[:qr_size] / 2.0 + cfg[:setter_gap]).round(2)
        texts = <<~XML
          <text x="#{grade_x}" y="#{grade_y}" font-size="#{cfg[:grade_fs]}" text-anchor="middle" dominant-baseline="central"
                fill="#{text_color}" font-family="DejaVu Sans, sans-serif">#{route[:grade_to_s]}</text>
          <text x="#{setter_x}" y="#{setter_y}" font-size="#{cfg[:setter_fs]}" text-anchor="middle" dominant-baseline="central"
                fill="#{text_color}" font-family="DejaVu Sans, sans-serif">#{openers_to_s(route[:openers])}</text>
        XML
      end

      body << path + texts + qr_element
    end

    { defs: defs.join, body: body.join }
  end

  # --- Full SVG page for one relay ----

  def generate_svg_for_relay(relay, group)
    result = group.length == 1 ? render_single_route(relay, group[0]) : render_multi_route(relay, group)

    <<~SVG
      <?xml version="1.0" encoding="UTF-8"?>
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 210 297">
        <defs>
          #{result[:defs]}
        </defs>
        <text x="105" y="30" font-size="#{@title_fs}" text-anchor="middle"
              font-family="DejaVu Sans, sans-serif">Relais n°#{relay}</text>
        #{result[:body]}
        <circle cx="#{CENTER_X}" cy="#{CENTER_Y}" r="5" fill="white" stroke="black" stroke-width="0.5"/>
        #{relay_box_svg(relay)}
      </svg>
    SVG
  end

  # --- PDF assembly ----

  def assemble_pdf(svg_list)
    pdf = Prawn::Document.new(page_size: 'A4', margin: 0)
    svg_list.each_with_index do |svg, idx|
      pdf.start_new_page if idx.positive?
      pdf.svg(svg, at: [0, pdf.bounds.top], width: pdf.bounds.width)
    end
    StringIO.new(pdf.render)
  end
end
