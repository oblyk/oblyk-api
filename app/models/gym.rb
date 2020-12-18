# frozen_string_literal: true

class Gym < ApplicationRecord
  include Geolocable
  include SoftDeletable
  include Searchable
  include Slugable

  has_one_attached :logo
  belongs_to :user, optional: true
  has_many :follows, as: :followable
  has_many :gym_administrators
  has_many :gym_grades
  has_many :gym_spaces

  def search_json
    JSON.parse(
      ApplicationController.render(
        template: 'api/v1/gyms/search.json',
        assigns: { gym: self }
      )
    )
  end

  validates :name, :latitude, :longitude, :address, :postal_code, :country, :city, :big_city, presence: true
end
