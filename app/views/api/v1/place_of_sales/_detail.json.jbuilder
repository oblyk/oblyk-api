# frozen_string_literal: true

json.extract! place_of_sale,
              :id,
              :name,
              :url,
              :description,
              :latitude,
              :longitude,
              :code_country,
              :country,
              :postal_code,
              :city,
              :region,
              :address,
              :guide_book_paper_id
json.creator do
  json.uuid place_of_sale.user&.uuid
  json.name place_of_sale.user&.full_name
  json.slug_name place_of_sale.user&.slug_name
end
json.history do
  json.extract! place_of_sale, :created_at, :updated_at
end
