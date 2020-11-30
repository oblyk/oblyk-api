# frozen_string_literal: true

json.extract! @user, :id, :first_name, :last_name, :date_of_birth, :genre, :description

json.follow_count @user.followers.count
json.follower_count @user.follows.count

json.localization do
  json.latitude @user.latitude
  json.longitude @user.longitude
end
