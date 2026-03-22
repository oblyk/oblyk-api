# frozen_string_literal: true

class PointsToSvg
  attr_accessor :points, :width, :height, :padding, :circle_radius

  def initialize(points, width: nil, height: nil, padding: nil, circle_radius: nil)
    self.points = points
    self.width = width || 800
    self.height = height || 800
    self.padding = padding || 1.2
    self.circle_radius = circle_radius || 40
  end

  def svg_file
    all_points = points.flat_map { |s| s[:points] }
    return nil if all_points.empty?

    min_x = all_points.map { |p| p[:x] }.min - padding
    max_x = all_points.map { |p| p[:x] }.max + padding
    min_y = all_points.map { |p| p[:y] }.min - padding
    max_y = all_points.map { |p| p[:y] }.max + padding

    range_x = max_x - min_x
    range_y = max_y - min_y
    scale = [width / range_x, height / range_y].min

    # CALCULATE VIEW PORT CENTER
    offset_x = (width  - range_x * scale) / 2.0
    offset_y = (height - range_y * scale) / 2.0

    polygons = points.map do |shape|
      points = shape[:points].map do |point|
        svg_x = (point[:x] - min_x) * scale + offset_x
        svg_y = (max_y - point[:y]) * scale + offset_y
        [svg_x.round(3), svg_y.round(3)]
      end

      next if points.size.zero?

      # POLYGONE CENTROID FOR CIRCLE
      cx = (points.sum { |pt| pt[0] } / points.size).round(3)
      cy = (points.sum { |pt| pt[1] } / points.size).round(3)

      polygon = "<polygon id='#{shape[:id]}' points='#{points.join(' ')}' />"
      circle = "<circle id='#{shape[:id]}' cx='#{cx}' cy='#{cy}' r='#{circle_radius}' />"
      [polygon, circle].join('')
    end

    xmlns = 'http://www.w3.org/2000/svg'
    view_box = "0 0 #{width} #{height}"

    "<svg xmlns='#{xmlns}' width='#{width}' height='#{height}' viewBox='#{view_box}'>#{polygons.join('')}</svg>"
  end
end
