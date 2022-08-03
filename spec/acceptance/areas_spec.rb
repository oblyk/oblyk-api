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

  get '/api/v1/public/areas/:id/guide_book_papers', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
    example 'Paper guide books' do
      explanation 'Get all paper guide books that cover the crags in the area `:id`'

      area = FactoryBot.create(:area_with_crag_and_routes)
      do_request({ id: area.id })
      expect(status).to eq 200
    end
  end

  get '/api/v1/public/areas/:id/crag_routes', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
    example 'Routes' do
      explanation '
      Get crag routes in the area `:id`<br><br>
      <u>Optional parameters :</u>
      <ul>
        <li><code>page</code> : Page number. set <code>all</code> for all results. default: <code>1</code></li>
        <li><code>page_limit</code> : number of results per page. default: <code>25</code></li>
      </ul>
      '

      area = FactoryBot.create(:area_with_crag_and_routes)
      do_request({ id: area.id })
      expect(status).to eq 200
    end
  end

  get '/api/v1/public/areas/:id/crag_routes/search_by_grades', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
    let(:grade) { '6b' }

    parameter :grade, 'Grade sought', type: :string, required: true

    example 'Search routes by grade' do
      explanation '
      Search route in area `id` filtered by grade. You can put two grades separated by a space to go up all the routes between these two grades _(see example below)_.<br><br>
      <u>Example for grade params:</u>
      <ul>
        <li><code>6a</code> : return all the 6a of the area</li>
        <li><code>6a 6a+</code> : return all the 6a and 6a+ of the area</li>
        <li><code>7</code> : return all the routes in the 7th degree (from 7a to 7c+)</li>
        <li><code>5c 6b</code> : return all routes between 5c and 6b</li>
      </ul>
      '

      area = FactoryBot.create(:area_with_crag_and_routes)
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
