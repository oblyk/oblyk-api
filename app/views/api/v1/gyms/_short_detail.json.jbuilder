# frozen_string_literal: true

json.extract! gym,
              :id,
              :name,
              :slug_name,
              :description,
              :email,
              :phone_number,
              :web_site
json.banner gym.banner.attached? ? url_for(gym.banner) : nil
json.logo gym.logo.attached? ? url_for(gym.logo) : nil

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
