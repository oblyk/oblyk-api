# frozen_string_literal: true

json.extract! gym,
              :id,
              :name,
              :slug_name,
              :description,
              :email,
              :phone_number,
              :web_site,
              :latitude,
              :longitude,
              :code_country,
              :country,
              :city,
              :big_city,
              :region,
              :address,
              :postal_code,
              :sport_climbing,
              :bouldering,
              :pan,
              :fun_climbing,
              :training_space
json.administered gym.administered?
json.banner gym.banner.attached? ? gym.banner_large_url : nil
json.logo gym.logo.attached? ? gym.logo_large_url : nil
