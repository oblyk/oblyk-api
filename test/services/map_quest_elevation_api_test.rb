# frozen_string_literal: true

require 'test_helper'

class MapQuestElevationApiTest < ActiveSupport::TestCase
  test 'it returns elevation profile when API call is successful' do
    coordinates = [
      { latitude: 45.1, longitude: 5.1 },
      { latitude: 45.2, longitude: 5.2 }
    ]

    mock_response = Minitest::Mock.new
    mock_response.expect :code, 200
    mock_response.expect :body, { elevationProfile: [{ height: 100 }, { height: 200 }] }.to_json

    expected_url = 'https://open.mapquestapi.com/elevation/v1/profile?key=NRSFXtuN1vAqUGY3ACLy0rPbIS02pjGI&shapeFormat=raw&latLngCollection=45.1,5.1,45.2,5.2'

    RestClient.stub :get, mock_response, [expected_url] do
      result = MapQuestElevationApi.elevations(coordinates)
      assert_equal [{ 'height' => 100 }, { 'height' => 200 }], result
    end

    assert_mock mock_response
  end

  test 'it returns nil if API response code is not 200' do
    coordinates = [{ latitude: 45.1, longitude: 5.1 }]

    mock_response = Minitest::Mock.new
    mock_response.expect :code, 404

    RestClient.stub :get, mock_response do
      result = MapQuestElevationApi.elevations(coordinates)
      assert_nil result
    end

    assert_mock mock_response
  end

  test 'it returns false if an error occurs during API call' do
    coordinates = [{ latitude: 45.1, longitude: 5.1 }]

    RestClient.stub :get, ->(_url) { raise StandardError } do
      result = MapQuestElevationApi.elevations(coordinates)
      assert_equal false, result
    end
  end
end
