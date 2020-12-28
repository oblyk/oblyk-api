# frozen_string_literal: true

json.extract! @user,
              :id,
              :first_name,
              :last_name,
              :date_of_birth,
              :genre,
              :email,
              :description,
              :latitude,
              :longitude
json.full_name @user.full_name
json.banner @user.banner.attached? ? url_for(@user.banner) : nil
json.avatar @user.avatar.attached? ? url_for(@user.avatar) : nil

json.follow_count @user.followers.count
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
