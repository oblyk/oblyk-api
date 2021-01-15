# frozen_string_literal: true

json.array! @place_of_sales do |place_of_sale|
  json.partial! 'api/v1/place_of_sales/detail', place_of_sale: place_of_sale
end
