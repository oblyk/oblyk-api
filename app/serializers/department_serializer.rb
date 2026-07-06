# frozen_string_literal: true

class DepartmentSerializer < BaseSerializer
  belongs_to :country

  attributes :id,
             :name,
             :app_path,
             :slug_name,
             :department_number,
             :name_prefix_type,
             :in_sentence_prefix_type,
             :country_id

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
