# frozen_string_literal: true

require 'test_helper'

class OpenElevationApiTest < ActiveSupport::TestCase
  test 'elevations returns results when API call is successful' do
    coordinates = [
      { latitude: 45.123, longitude: 5.456 },
      { latitude: '46.789', longitude: '6.123' }
    ]

    expected_float_coordinates = [
      { latitude: 45.123, longitude: 5.456 },
      { latitude: 46.789, longitude: 6.123 }
    ]

    mock_response = Minitest::Mock.new
    mock_response.expect :code, 200
    mock_response.expect :body, { results: [{ latitude: 45.123, longitude: 5.456, elevation: 100 }, { latitude: 46.789, longitude: 6.123, elevation: 200 }] }.to_json

    expected_url = 'https://api.open-elevation.com/api/v1/lookup'
    expected_payload = { locations: expected_float_coordinates }.to_json
    expected_headers = { content_type: :json, accept: :json }

    RestClient.stub :post, mock_response, [expected_url, expected_payload, expected_headers] do
      results = OpenElevationApi.elevations(coordinates)
      assert_equal 2, results.size
      assert_equal 100, results[0]['elevation']
      assert_equal 200, results[1]['elevation']
    end

    assert_mock mock_response
  end

  test 'elevations returns nil when API returns non-200 code' do
    coordinates = [{ latitude: 45.123, longitude: 5.456 }]

    mock_response = Minitest::Mock.new
    mock_response.expect :code, 404

    RestClient.stub :post, mock_response do
      results = OpenElevationApi.elevations(coordinates)
      assert_nil results
    end

    assert_mock mock_response
  end

  test 'elevations returns false when API call raises an error' do
    coordinates = [{ latitude: 45.123, longitude: 5.456 }]

    RestClient.stub :post, ->(_url, _payload, _headers) { raise StandardError } do
      results = OpenElevationApi.elevations(coordinates)
      assert_equal false, results
    end
  end
end
