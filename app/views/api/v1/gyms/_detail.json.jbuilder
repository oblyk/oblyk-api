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

json.follow_count gym.follows.count

json.creator do
  json.id gym.user_id
  json.name gym.user&.full_name
end
json.history do
  json.extract! gym, :created_at, :updated_at
end
