# frozen_string_literal: true

json.extract! user,
              :id,
              :uuid,
              :first_name,
              :last_name,
              :slug_name,
              :genre,
              :description,
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
              :public_profile,
              :public_outdoor_ascents,
              :public_indoor_ascents,
              :last_activity_at
json.age user.age
json.followers_count user.follows.count || 0
json.subscribes_count user.subscribes.count
json.videos_count user.videos.count
json.photos_count user.photos.count
json.full_name user.full_name
json.banner user.banner.attached? ? user.banner_large_url : nil
json.avatar user.avatar.attached? ? user.avatar_large_url : nil
