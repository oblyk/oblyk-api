# frozen_string_literal: true

class Country < ApplicationRecord
  include RouteFigurable

  has_many :departments
  has_many :crags, through: :departments
  has_many :crag_routes, through: :crags
  has_many :gyms, through: :departments

  def app_path
    "/escalade-en/#{slug_name}"
  end

  def summary_to_json
    Rails.cache.fetch("#{cache_key_with_version}/summary_country", expires_in: 28.days) do
      {
        id: id,
        name: name,
        app_path: app_path,
        code_country: code_country,
        slug_name: slug_name
      }
    end
  end

  def detail_to_json
    summary_to_json
  end
end
