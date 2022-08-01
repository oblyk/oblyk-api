# frozen_string_literal: true

FactoryBot.define do
  factory :area do
    name { 'Drôme provençale' }

    factory :area_with_crags do
      after(:create) do |area|
        # Create crag
        crag = create :crag
        create :area_crag, crag: crag, area: area
      end
    end

    factory :area_with_crag_and_routes do
      after(:create) do |area|
        # Create crag
        crag = create :crag_detail
        create :area_crag, crag: crag, area: area
      end
    end
  end
end
