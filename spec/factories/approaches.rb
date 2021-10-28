# frozen_string_literal: true

FactoryBot.define do
  factory :approach do
    description { "Depuis le parking jusqu'à la falaise" }
    polyline { [[44.46635, 5.05527], [44.46653, 5.05527], [44.46663, 5.05526], [44.46669, 5.05554], [44.46674, 5.05573], [44.46671, 5.05586], [44.46664, 5.05605]] }
    approach_type { 'steep_ascent' }
    crag
  end
end
