# frozen_string_literal: true

class CountrySerializer < BaseSerializer
  attributes :id,
             :name,
             :app_path,
             :slug_name,
             :code_country

  attribute :geo_polygon, if: proc { |object, params|
    params[:with_geo_polygon] == true ? object.geo_polygon : nil
  }

  attribute :history do |object|
    {
      created_at: object.created_at,
      updated_at: object.updated_at
    }
  end
end
