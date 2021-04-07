# frozen_string_literal: true

class OrganizationGym < ApplicationRecord
  belongs_to :gym
  belongs_to :organization
end
