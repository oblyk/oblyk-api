# frozen_string_literal: true

class Word < ApplicationRecord
  has_one_attached :picture
  belongs_to :user, optional: true

  validates :name, :definition, presence: true
end
