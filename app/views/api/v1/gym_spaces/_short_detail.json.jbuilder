# frozen_string_literal: true

json.extract! gym_space,
              :id,
              :name,
              :slug_name,
              :description,
              :order,
              :climbing_type,
              :banner_color,
              :banner_bg_color,
              :banner_opacity,
              :scheme_bg_color,
              :scheme_height,
              :scheme_width,
              :latitude,
              :longitude,
              :published_at
json.banner gym_space.banner.attached? ? url_for(gym_space.banner) : nil
json.plan gym_space.plan.attached? ? url_for(gym_space.plan) : nil