# frozen_string_literal: true

FactoryBot.define do
  factory :word do
    trait :climbing do
      name { 'Climbing' }
      definition { 'Best sport ever' }
    end

    trait :oblyk do
      name { 'Oblyk' }
      definition { 'Best climbing community ever : )' }
    end
  end
end
