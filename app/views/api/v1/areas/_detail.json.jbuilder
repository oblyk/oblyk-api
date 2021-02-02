# frozen_string_literal: true

json.extract! area, :id, :name, :slug_name
json.crags_count area.crags.count
json.crag_routes_count area.crag_routes_count
json.photo do
  json.id area.photo&.id
  json.url url_for(area.photo.picture) if area.photo
  json.thumbnail_url area.photo.thumbnail_url if area.photo
  json.illustrable_type area.photo.illustrable_type if area.photo
  json.illustrable_name area.photo.illustrable.rich_name if area.photo
end
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
  json.id area.user_id
  json.name area.user&.full_name
end
json.history do
  json.extract! area, :created_at, :updated_at
end

json.routes_figures do
  json.routes_count area.crag_routes_count
  json.grade do
    json.min_value area.easiest_route.min_grade_value
    json.min_text area.easiest_route.min_grade_text
    json.max_value area.hardest_route.max_grade_value
    json.max_text area.hardest_route.max_grade_text
  end
end
