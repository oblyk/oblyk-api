# frozen_string_literal: true

json.extract! @user,
              :id,
              :uuid,
              :first_name,
              :last_name,
              :slug_name,
              :date_of_birth,
              :genre,
              :email,
              :description,
              :latitude,
              :longitude,
              :localization,
              :partner_search,
              :partner_latitude,
              :partner_longitude,
              :bouldering,
              :sport_climbing,
              :multi_pitch,
              :trad_climbing,
              :aid_climbing,
              :deep_water,
              :via_ferrata,
              :pan,
              :grade_max,
              :grade_min,
              :language,
              :public_profile,
              :public_outdoor_ascents,
              :public_indoor_ascents,
              :email_notifiable_list
json.full_name @user.full_name
json.banner @user.banner.attached? ? url_for(@user.banner) : nil
json.avatar @user.avatar.attached? ? url_for(@user.avatar) : nil

json.subscribes_count @user.subscribes.count
json.follower_count @user.follows.count
json.photo_count @user.photos.count

json.gyms do
  json.array! @user.gyms do |gym|
    json.id gym.id
    json.name gym.name
    json.slug_name gym.slug_name
    json.logo gym.logo.attached? ? url_for(gym.logo) : nil
  end
end
