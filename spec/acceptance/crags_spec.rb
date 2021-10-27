# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Crags' do
  explanation 'The most complete and interesting part of the APIs, the climbing crag endpoints !'

  get '/api/v1/public/crags/crags_around', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
    let(:latitude) { 44.470 }
    let(:longitude) { 5.060 }
    let(:distance) { 10 }

    parameter :latitude, 'Latitude of the desired point', type: :decimal, required: true
    parameter :longitude, 'Longitude of the desired point', type: :decimal, required: true
    parameter :distance, 'Distance in kilometres from the research', type: :integer, default: 20

    example 'Crags around lat, lng & distance' do
      explanation 'Find crags list within a distance of a gps point.'

      FactoryBot.create :crag
      do_request({ latitude: latitude, longitude: longitude, distance: distance })
      expect(status).to eq 200
    end
  end

  get '/api/v1/public/crags/:id', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
    example 'Show' do
      explanation 'Show crag `:id`'

      crag = FactoryBot.create(:crag_detail)
      do_request({ id: crag.id })
      expect(status).to eq 200
    end
  end

  get '/api/v1/public/crags/search', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
    let(:query) { 'aures' }

    parameter :query, 'Crag to search', type: :string, required: true

    example 'Search' do
      explanation 'Search crags by `:query` name'

      FactoryBot.create(:crag_detail)
      do_request({ query: query })
      expect(status).to eq 200
    end
  end

  get '/api/v1/public/crags/:id/crag_routes', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
    example 'Routes' do
      explanation 'Get the list of routes of the crag `:id`.'

      crag = FactoryBot.create(:crag_detail)
      do_request({ id: crag.id })
      expect(status).to eq 200
    end
  end

  get '/api/v1/public/crags/:id/crag_sectors', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
    example 'Sectors' do
      explanation 'Get the list of sectors of the crag `:id`.'

      crag = FactoryBot.create(:crag_detail)
      do_request({ id: crag.id })
      expect(status).to eq 200
    end
  end

  get '/api/v1/public/crags/:id/guides', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
    example 'Guide books' do
      explanation 'Get the list of guides (paper, web and pdf) in relation with crag `:id`.'

      crag = FactoryBot.create(:crag_detail)
      do_request({ id: crag.id })
      expect(status).to eq 200
    end
  end

  get '/api/v1/public/crags/:id/route_figures', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
    example 'Routes figures' do
      explanation 'Get the routes statistics of crag `:id`.'

      crag = FactoryBot.create(:crag_detail)
      do_request({ id: crag.id })
      expect(status).to eq 200
    end
  end

  get '/api/v1/public/crags/:id/parks', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
    example 'Parks' do
      explanation 'Get the list of parks in relation with crag `:id`.'

      crag = FactoryBot.create(:crag_detail)
      do_request({ id: crag.id })
      expect(status).to eq 200
    end
  end

  get '/api/v1/public/crags/:id/approaches', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
    example 'Approaches' do
      explanation 'Get the list of approaches in relation with crag `:id`.'

      crag = FactoryBot.create(:crag_detail)
      do_request({ id: crag.id })
      expect(status).to eq 200
    end
  end

  # Part of test without API documentation
  context 'No documentation part', document: false do
    get '/api/v1/public/crags', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
      example 'Index' do
        explanation 'Get all crags'

        FactoryBot.create :crag
        do_request
        expect(status).to eq 200
      end
    end

    get '/api/v1/public/crags/random', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
      example 'Random' do
        explanation 'Get random crag'

        FactoryBot.create(:crag_detail)
        do_request
        expect(status).to eq 200
      end
    end
  end
end
