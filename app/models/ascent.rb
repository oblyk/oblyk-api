# frozen_string_literal: true

class Ascent < ApplicationRecord
  belongs_to :user

  validates :released_at, presence: true
end
