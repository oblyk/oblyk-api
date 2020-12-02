# frozen_string_literal: true

class Crag < ApplicationRecord
  include Geolocable
  include SoftDeletable

  has_one_attached :picture
  belongs_to :user, optional: true
  has_many :comments, as: :commentable
  has_many :links, as: :linkable
  has_many :follows, as: :followable
  has_many :alerts, as: :alertable
  has_many :parks
  has_many :crag_sectors
  alias_attribute :sectors, :crag_sectors
  has_many :area_crags
  has_many :areas, through: :area_crags

  validates :name, :latitude, :longitude, presence: true
  validates :rain, inclusion: { in: Rain::LIST }, allow_nil: true
  validates :sun, inclusion: { in: Sun::LIST }, allow_nil: true
  validate :validate_rocks

  private

  def validate_rocks
    return if rocks&.count&.zero?

    rocks.each do |rock|
      errors.add(:rocks, I18n.t('activerecord.errors.messages.inclusion')) if Rock::LIST.exclude? rock['name']
    end
  end
end
