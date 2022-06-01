# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Areas' do
  explanation 'Areas are groupings of climbing sites, they allow the creation of logical groups such as the "Forest of Fontainebleau", or the Calanques'

  get '/api/v1/public/areas/search', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
    let(:query) { 'drome' }

    parameter :query, 'Area to search', type: :string, required: true

    example 'Search' do
      explanation 'Search area by `:query` name'

      FactoryBot.create :area
      do_request({ query: query })
      expect(status).to eq 200
    end
  end

  get '/api/v1/public/areas', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
    example 'Index' do
      explanation 'Show oblyk areas'

      FactoryBot.create(:area, { name: 'Forêt de Fontainebleau' })
      FactoryBot.create(:area, { name: 'Parc national des Calanques' })

      do_request
      expect(status).to eq 200
    end
  end

  get '/api/v1/public/areas/:id', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
    example 'Show' do
      explanation 'Show area `:id`'

      area = FactoryBot.create(:area_with_crags)
      do_request({ id: area.id })
      expect(status).to eq 200
    end
  end

  get '/api/v1/public/areas/:id/crags', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
    example 'Crags' do
      explanation 'Get crags in area `:id`'

      area = FactoryBot.create(:area_with_crags)
      do_request({ id: area.id })
      expect(status).to eq 200
    end
  end

  get '/api/v1/public/areas/:id/photos', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
    example 'Photos' do
      explanation 'Get photos of the climbing sites in the area `:id`'

      area = FactoryBot.create(:area_with_crags)
      do_request({ id: area.id })
      expect(status).to eq 200
    end
  end

  get '/api/v1/public/areas/:id/geo_json', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
    example 'GeoJson' do
      explanation 'Get geo_json of the climbing sites, parks, approach, sectors in the area `:id`'

      area = FactoryBot.create(:area_with_crags)
      do_request({ id: area.id })
      expect(status).to eq 200
    end
  end
end
