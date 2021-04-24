# frozen_string_literal: true

json.partial! 'api/v1/areas/short_detail', area: area
json.crags_count area.crags.count
json.crag_routes_count area.crag_routes_count
json.area_crags do
  json.array! area.area_crags do |area_crag|
    json.id area_crag.id
    json.crags do
      json.extract! area_crag.crag,
                    :id,
                    :name
    end
  end
end
json.creator do
  json.uuid area.user&.uuid
  json.name area.user&.full_name
  json.slug_name area.user&.slug_name
end
json.history do
  json.extract! area, :created_at, :updated_at
end

json.routes_figures do
  json.routes_count area.crag_routes_count
  json.grade do
    json.min_value area.easiest_route&.min_grade_value
    json.min_text area.easiest_route&.min_grade_text
    json.max_value area.hardest_route&.max_grade_value
    json.max_text area.hardest_route&.max_grade_text
  end
end
