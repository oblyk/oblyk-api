# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Words' do
  explanation 'The climbing glossary create by climbers community'

  get '/api/v1/public/words', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
    let(:page) { 1 }

    parameter :page, 'Page of pagination', type: :integer, default: 1

    example 'Index' do
      explanation 'List words in glossary'

      FactoryBot.create :word, :climbing
      FactoryBot.create :word, :oblyk

      do_request({ page: page })
      expect(status).to eq 200
    end
  end

  get '/api/v1/public/words/search', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
    let(:query) { 'climbing' }

    parameter :query, 'word to search', type: :string, required: true

    example 'Search' do
      explanation 'Search words in glossary'

      FactoryBot.create :word, :climbing

      do_request({ query: query })
      expect(status).to eq 200
    end
  end

  get '/api/v1/public/words/:id', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
    example 'Show' do
      explanation 'Show word by `:id`'

      word = FactoryBot.create :word, :oblyk
      do_request({ id: word.id })
      expect(status).to eq 200
    end
  end
end
