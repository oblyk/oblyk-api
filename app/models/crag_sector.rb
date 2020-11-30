# frozen_string_literal: true

class CragSector < ApplicationRecord
  include Geolocable
  include SoftDeletable

  has_one_attached :picture
  belongs_to :user, optional: true
  belongs_to :crag
  has_many :comments, as: :commentable
  has_many :links, as: :linkable
  has_many :follows, as: :followable
  has_many :alerts, as: :alertable

  validates :name, presence: true
  validates :rain, inclusion: { in: Rain::LIST }, allow_nil: true
  validates :sun, inclusion: { in: Sun::LIST }, allow_nil: true
end
