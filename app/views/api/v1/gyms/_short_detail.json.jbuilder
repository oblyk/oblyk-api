# frozen_string_literal: true

json.extract! gym,
              :id,
              :name,
              :description,
              :email,
              :phone_number,
              :web_site

json.climbing_type do
  json.extract! gym,
                :sport_climbing,
                :bouldering,
                :pan,
                :fun_climbing,
                :training_space
end
json.localization do
  json.extract! gym,
                :latitude,
                :longitude,
                :code_country,
                :country,
                :city,
                :big_city,
                :region,
                :address,
                :postal_code
end
