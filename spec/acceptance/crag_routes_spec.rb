# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'CragRoutes' do
  explanation '
  The `crag_routes` represent a line of boulder, routes, multi pitch, trad, aid, deep water or via ferrata.<br>
  A `crag_route` necessarily belongs to a climbing site (`crag`) and optionally to a sector of a crag (`crag_sectors`).
  '

  get '/api/v1/public/crag_routes/:id', headers: { 'HttpApiAccessToken' => 'oblyk-api-access-token' } do
    example 'Show' do
      explanation 'Show crag_route `:id`'

      crag = FactoryBot.create(:crag)
      crag_route = FactoryBot.create(:crag_route, :joly, crag: crag, crag_sector: nil)
      do_request({ id: crag_route.id })
      expect(status).to eq 200
    end
  end
end
