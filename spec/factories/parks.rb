# frozen_string_literal: true

FactoryBot.define do
  factory :park do
    description { 'Parking principal' }
    latitude { 44.46635 }
    longitude { 5.05527 }
    crag
  end
end
