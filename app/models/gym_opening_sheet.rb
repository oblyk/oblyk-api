# frozen_string_literal: true

class GymOpeningSheet < ApplicationRecord
  include Archivable
  include StripTagable

  belongs_to :gym

  validates :title, :number_of_columns, presence: true

  attr_accessor :gym_space_id, :gym_route_ids

  def summary_to_json
    {
      id: id,
      title: title,
      description: description,
      archived_at: archived_at,
      gym_id: gym_id,
      gym: {
        id: gym.id,
        slug_name: gym.slug_name
      },
      history: {
        created_at: created_at,
        updated_at: updated_at
      }
    }
  end

  def detail_to_json
    summary_to_json.merge(
      {
        number_of_columns: number_of_columns,
        row_json: row_json
      }
    )
  end

  def build_row_json
    data = {}

    gym_routes = GymRoute.mounted
                         .joins(gym_sector: :gym_space)
                         .where(gym_spaces: { gym_id: gym_id })
                         .order(:min_grade_value)
    gym_routes = gym_routes.where(gym_spaces: { id: gym_space_id }) if gym_space_id
    gym_routes = gym_routes.where(id: gym_route_ids) if gym_route_ids

    gym_sectors = if gym_space_id
                    GymSector.joins(:gym_space).where(gym_spaces: { gym_id: gym_id, id: gym_space_id })
                  elsif gym_route_ids
                    GymSector.joins(:gym_space, :gym_routes).where(
                      gym_spaces: { gym_id: gym_id },
                      gym_routes: { id: gym_route_ids }
                    )
                  else
                    GymSector.joins(:gym_space, :gym_routes).where(gym_spaces: { gym_id: gym_id })
                  end
    gym_sectors = gym_sectors.order(:order, :name)

    gym_sectors.each do |gym_sector|
      data[gym_sector.id] = {
        sector: {
          name: gym_sector.name,
          id: gym_sector.id
        },
        build_routes: [],
        routes: []
      }
      number_of_columns.times do
        data[gym_sector.id][:build_routes] << {
          open: { grade: nil, hold_color: nil, text_hold_color: 'inherit', type: 'open' },
          to_open: { grade: nil, hold_color: nil, text_hold_color: 'inherit', type: 'to_open' },
          opened: { grade: nil, hold_color: nil, text_hold_color: 'inherit', type: 'opened' }
        }
      end
    end

    gym_routes.each do |gym_route|
      data[gym_route.gym_sector_id][:build_routes].each_with_index do |route, index|
        next if route[:open][:id].present?
        next if data[gym_route.gym_sector_id][:build_routes][index].blank?

        data[gym_route.gym_sector_id][:build_routes][index][:open] = {
          number: index + 1,
          id: gym_route.id,
          type: 'open',
          grade: gym_route.min_grade_text,
          hold_color: gym_route.hold_colors&.first,
          tag_color: gym_route.tag_colors&.first,
          text_hold_color: Color.black_or_white_rgb(gym_route.hold_colors&.first || 'inherit'),
          text_tag_color: Color.black_or_white_rgb(gym_route.tag_colors&.first || 'inherit')
        }
        break
      end
    end

    data = data.map(&:second)
    data.each_with_index do |row, row_index|
      row[:build_routes].each do |route|
        data[row_index][:routes] << route[:open]
        data[row_index][:routes] << route[:to_open]
        data[row_index][:routes] << route[:opened]
      end
      data[row_index].delete(:build_routes)
    end
    self.row_json = data
  end
end
