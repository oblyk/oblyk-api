# frozen_string_literal: true

FactoryBot.define do
  factory :crag_route do
    trait :transgression do
      name { 'Transgression' }
      height { 30 }
      open_year { 1998 }
      sections { [{ grade: '7c', height: 30, grade_value: 41, incline_type: 'vertical', climbing_type: 'sport_climbing' }] }
      opener { 'François Crespo' }
      climbing_type { 'sport_climbing' }
      incline_type { 'vertical' }
    end

    trait :joly do
      name { 'Joly' }
      height { 16 }
      open_year { 1997 }
      sections { [{ grade: '6b', height: 16, grade_value: 33, incline_type: 'vertical', climbing_type: 'sport_climbing' }] }
      opener { 'François Crespo' }
      climbing_type { 'sport_climbing' }
      incline_type { 'vertical' }
    end

    crag
    crag_sector
  end
end
