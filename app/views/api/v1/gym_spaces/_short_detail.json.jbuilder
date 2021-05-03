# frozen_string_literal: true

json.extract! gym_space,
              :id,
              :gym_grade_id,
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
json.banner gym_space.banner.attached? ? gym_space.banner_large_url : nil
json.plan gym_space.plan.attached? ? gym_space.plan_large_url : nil
