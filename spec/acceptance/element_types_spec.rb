# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Types' do
  explanation 'This part of the API documentation shows you the different types of elements that oblyk uses, such as bolt types, sunlight, rain exposure, etc.'

  get '/api/v1/public/bolts', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
    example 'Bolts' do
      explanation 'List of the types of bolts that can be found on a climbing route.'
      do_request
      expect(status).to eq 200
    end
  end

  get '/api/v1/public/anchors', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
    example 'Anchors' do
      explanation 'List of the types of anchors that can be found on a climbing route.'
      do_request
      expect(status).to eq 200
    end
  end

  get '/api/v1/public/climbs', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
    example 'Climbs' do
      explanation 'List of the types of climbs.'
      do_request
      expect(status).to eq 200
    end
  end

  get '/api/v1/public/inclines', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
    example 'Inclines' do
      explanation 'List of the types of inclines that can be found on a climbing route.'
      do_request
      expect(status).to eq 200
    end
  end

  get '/api/v1/public/rains', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
    example 'Rains' do
      explanation 'List of types of exposures to rains from a crag.'
      do_request
      expect(status).to eq 200
    end
  end

  get '/api/v1/public/receptions', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
    example 'Receptions' do
      explanation 'List of boulder receptions types.'
      do_request
      expect(status).to eq 200
    end
  end

  get '/api/v1/public/rocks', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
    example 'Rocks' do
      explanation 'List of types of rocks from a crag.'
      do_request
      expect(status).to eq 200
    end
  end

  get '/api/v1/public/starts', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
    example 'Starts' do
      explanation 'List of boulder start types.'
      do_request
      expect(status).to eq 200
    end
  end

  get '/api/v1/public/suns', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
    example 'Suns' do
      explanation 'List of types of suns exposures a crag can have.'
      do_request
      expect(status).to eq 200
    end
  end

  # Part of test without API documentation
  context 'No documentation part', document: false do
    get '/api/v1/public/alert-types', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
      example 'Suns' do
        explanation 'List of alert types.'
        do_request
        expect(status).to eq 200
      end
    end

    get '/api/v1/public/approach-types', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
      example 'Suns' do
        explanation 'List of approach types types.'
        do_request
        expect(status).to eq 200
      end
    end
  end
end
