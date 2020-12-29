# frozen_string_literal: true

class Word < ApplicationRecord
  include Slugable

  has_one_attached :picture
  belongs_to :user, optional: true

  validates :name, :definition, presence: true

  default_scope { order(:name) }
end
