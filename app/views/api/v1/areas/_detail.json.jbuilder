# frozen_string_literal: true

json.extract! area, :name, :slug_name
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
