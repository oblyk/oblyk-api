# frozen_string_literal: true

class PlaceOfSale < ApplicationRecord
  include Geolocable

  belongs_to :user, optional: true
  belongs_to :guide_book_paper
  has_many :reports, as: :reportable

  validates :name, presence: true
end
