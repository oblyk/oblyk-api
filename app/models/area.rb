# frozen_string_literal: true

class Area < ApplicationRecord
  include Slugable

  belongs_to :user, optional: true
  has_many :area_crags, dependent: :destroy
  has_many :crags, through: :area_crags
  has_many :reports, as: :reportable

  validates :name, presence: true
end
