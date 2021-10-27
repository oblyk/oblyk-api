# frozen_string_literal: true

FactoryBot.define do
  factory :crag do
    name { 'Rocher des aures' }
    latitude { '44.469592' }
    longitude { '5.058089' }
    rain { 'exposed' }
    sun { 'sunny_all_day' }
    rocks { ['limestone'] }
    city { 'Roche-Saint-Secret-Béconne' }
    region { 'Drôme' }
    country { 'France' }
    code_country { 'FR' }
    sport_climbing { true }
    south { true }

    factory :crag_detail do
      after(:create) do |crag|

        # Create area
        area = create :area
        create :area_crag, crag: crag, area: area

        # Create route and sectors
        sector = create :crag_sector, :rose_des_sables, crag: crag
        create :crag_route, :transgression, crag: crag, crag_sector: sector
        create :crag_route, :joly, crag: crag, crag_sector: sector

        # Create guide books
        guide_book_paper = create :guide_book_paper
        create :guide_book_paper_crag, crag: crag, guide_book_paper: guide_book_paper
        create :guide_book_web, crag: crag

        # Park and approach
        create :park, crag: crag
        create :approach, crag: crag

        crag.reload
      end
    end
  end
end
