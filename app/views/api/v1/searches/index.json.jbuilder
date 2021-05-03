# frozen_string_literal: true
json.array! @responses do |response|
  json.class_name response.class.name
  json.id response.id
  json.name response.name
  json.photo response.photo.large_url if defined? response.photo
  json.country response.country
  json.region response.region
  json.city response.city
end
