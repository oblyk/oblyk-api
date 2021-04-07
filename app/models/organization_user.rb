# frozen_string_literal: true

class OrganizationUser < ApplicationRecord
  belongs_to :user
  belongs_to :organization
end
