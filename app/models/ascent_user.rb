# frozen_string_literal: true

class AscentUser < ApplicationRecord
  belongs_to :user
  belongs_to :ascent

  validates :ascent, uniqueness: { scope: :user }
end
