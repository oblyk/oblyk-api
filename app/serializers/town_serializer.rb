# frozen_string_literal: true

class TownSerializer < BaseSerializer
  belongs_to :department

  attributes :id,
             :name,
             :app_path,
             :slug_name,
             :latitude,
             :longitude,
             :population,
             :town_code,
             :zipcode,
             :department_id

  attribute :history do |object|
    {
      created_at: object.created_at,
      updated_at: object.updated_at
    }
  end
end
