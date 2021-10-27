# frozen_string_literal: true

FactoryBot.define do
  factory :crag_sector do
    trait :rose_des_sables do
      name { 'Rose des sables' }
      rain { 'exposed' }
      sun { 'sunny_all_day' }
    end

    trait :les_lames do
      name { 'Les lames' }
    end

    crag
  end
end
