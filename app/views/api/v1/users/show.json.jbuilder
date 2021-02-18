# frozen_string_literal: true

json.extract! @user,
              :uuid,
              :first_name,
              :last_name,
              :slug_name,
              :date_of_birth,
              :genre,
              :description,
              :localization,
              :partner_search,
              :bouldering,
              :sport_climbing,
              :multi_pitch,
              :trad_climbing,
              :aid_climbing,
              :deep_water,
              :via_ferrata,
              :pan,
              :grade_max,
              :grade_min
json.full_name @user.full_name
json.banner @user.banner.attached? ? url_for(@user.banner) : nil
json.avatar @user.avatar.attached? ? url_for(@user.avatar) : nil
