# frozen_string_literal: true

if @group_by.blank?
  json.array! @gym_routes do |gym_route|
    json.partial! 'api/v1/gym_routes/detail', gym_route: gym_route
  end
elsif @group_by == 'sector'
  json.sectors do
    json.array! @gym_routes do |sector|
      json.sector do
        json.partial! 'api/v1/gym_sectors/short_detail', gym_sector: sector[:sector]
      end
      json.routes do
        json.array! sector[:routes] do |gym_route|
          json.partial! 'api/v1/gym_routes/detail', gym_route: gym_route
        end
      end
    end
  end
elsif @group_by == 'opened_at'
  json.opened_at do
    json.array! @gym_routes do |opened_at|
      json.opened_at opened_at[0]
      json.routes do
        json.array! opened_at[1][:routes] do |gym_route|
          json.partial! 'api/v1/gym_routes/detail', gym_route: gym_route
        end
      end
    end
  end
elsif @group_by == 'grade'
  json.grade do
    json.array! @gym_routes do |grade|
      json.grade grade[0]
      json.routes do
        json.array! grade[1][:routes] do |gym_route|
          json.partial! 'api/v1/gym_routes/detail', gym_route: gym_route
        end
      end
    end
  end
end
