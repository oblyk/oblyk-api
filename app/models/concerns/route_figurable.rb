# frozen_string_literal: true

module RouteFigurable
  extend ActiveSupport::Concern

  def route_figures(include_crags: false)
    figures = {
      section_count: 0,
      route_count: 0,
      grade: {
        min: {
          value: nil,
          text: nil,
          crag_route: nil
        },
        max: {
          value: nil,
          text: nil,
          crag_route: nil
        }
      },
      climbing_types: {
        sport_climbing: 0,
        bouldering: 0,
        multi_pitch: 0,
        trad_climbing: 0,
        aid_climbing: 0,
        deep_water: 0,
        via_ferrata: 0
      },
      degrees: {
        '1' => 0,
        '2' => 0,
        '3' => 0,
        '4' => 0,
        '5' => 0,
        '6' => 0,
        '7' => 0,
        '8' => 0,
        '9' => 0
      },
      levels: {
        '1a' => 0, '1b' => 0, '1c' => 0,
        '2a' => 0, '2b' => 0, '2c' => 0,
        '3a' => 0, '3b' => 0, '3c' => 0,
        '4a' => 0, '4b' => 0, '4c' => 0,
        '5a' => 0, '5b' => 0, '5c' => 0,
        '6a' => 0, '6b' => 0, '6c' => 0,
        '7a' => 0, '7b' => 0, '7c' => 0,
        '8a' => 0, '8b' => 0, '8c' => 0,
        '9a' => 0, '9b' => 0, '9c' => 0
      }
    }
    
    routes = if include_crags
               crag_routes.includes(:photo, crag: { photo: { picture_attachment: :blob } }, crag_sector: { photo: { picture_attachment: :blob } })
             else
               crag_routes.includes(:photo, crag_sector: { photo: { picture_attachment: :blob } })
             end
    routes.find_each do |crag_route|
      figures[:climbing_types][crag_route.climbing_type.to_sym] += 1
      figures[:route_count] += 1

      if crag_route.max_grade_value.positive? && (figures[:grade][:min][:value].nil? || figures[:grade][:min][:value] > crag_route.max_grade_value)
        figures[:grade][:min][:value] = crag_route.max_grade_value
        figures[:grade][:min][:text] = crag_route.max_grade_text
        figures[:grade][:min][:crag_route] = crag_route.summary_to_json(with_crag_in_sector: false)
      end

      if crag_route.max_grade_value.positive? && (figures[:grade][:max][:value].nil? || figures[:grade][:max][:value] < crag_route.max_grade_value)
        figures[:grade][:max][:value] = crag_route.max_grade_value
        figures[:grade][:max][:text] = crag_route.max_grade_text
        figures[:grade][:max][:crag_route] = crag_route.summary_to_json(with_crag_in_sector: false)
      end

      crag_route.sections.each do |section|
        next unless section['grade_value']&.positive?

        figures[:section_count] += 1
        figures[:degrees][Grade.degree(section['grade_value'])] += 1
        figures[:levels][Grade.level(section['grade_value'])] += 1
      end
    end
    figures
  end
end
