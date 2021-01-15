# frozen_string_literal: true

class Gym < ApplicationRecord
  include Geolocable
  include SoftDeletable
  include Searchable
  include Slugable

  has_one_attached :logo
  has_one_attached :banner
  belongs_to :user, optional: true
  has_many :follows, as: :followable
  has_many :gym_administrators
  has_many :gym_grades
  has_many :gym_spaces
  has_many :reports, as: :reportable

  validates :logo, blob: { content_type: :image }, allow_nil: true
  validates :banner, blob: { content_type: :image }, allow_nil: true

  def search_json
    JSON.parse(
      ApplicationController.render(
        template: 'api/v1/gyms/search.json',
        assigns: { gym: self }
      )
    )
  end

  validates :name, :latitude, :longitude, :address, :postal_code, :country, :city, :big_city, presence: true

  def administered?
    assigned_at.present?
  end

  def administered!
    self.assigned_at ||= Time.current
    save
  end

  def climbing_key
    key = ''
    key += bouldering || pan ? '1' : '0'
    key += sport_climbing ? '1' : '0'
    key += fun_climbing ? '1' : '0'
    key
  end

  def thumbnail_banner_url
    Rails.application.routes.url_helpers.rails_representation_url(banner.variant(resize: '300x300').processed, only_path: true)
  end
end
