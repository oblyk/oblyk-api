# frozen_string_literal: true

require 'test_helper'

class GoogleMapApiTest < ActiveSupport::TestCase
  test 'elevations returns results when API call is successful' do
    coordinates = [
      { latitude: 45.1, longitude: 5.1 },
      { latitude: 45.2, longitude: 5.2 }
    ]

    mock_response = Minitest::Mock.new
    mock_response.expect :code, 200
    mock_response.expect :body, { results: [{ elevation: 100 }, { elevation: 200 }] }.to_json

    expected_url = "#{GoogleMapApi::BASE_URL}/elevation/json"
    expected_params = {
      params: {
        locations: '45.1,5.1|45.2,5.2',
        key: GoogleMapApi::GOOGLE_KEY
      }
    }

    RestClient.stub :get, mock_response, [expected_url, expected_params] do
      result = GoogleMapApi.elevations(coordinates)
      assert_equal [{ 'elevation' => 100 }, { 'elevation' => 200 }], result
    end

    assert_mock mock_response
  end

  test 'elevations returns nil if API response code is not 200' do
    coordinates = [{ latitude: 45.1, longitude: 5.1 }]

    mock_response = Minitest::Mock.new
    mock_response.expect :code, 404

    RestClient.stub :get, mock_response do
      result = GoogleMapApi.elevations(coordinates)
      assert_nil result
    end

    assert_mock mock_response
  end

  test 'elevations returns false if an error occurs' do
    coordinates = [{ latitude: 45.1, longitude: 5.1 }]

    RestClient.stub :get, ->(_url, _params) { raise StandardError } do
      result = GoogleMapApi.elevations(coordinates)
      assert_equal false, result
    end
  end

  test 'places returns candidates when API call is successful' do
    query = 'Grenoble'

    mock_response = Minitest::Mock.new
    mock_response.expect :code, 200
    mock_response.expect :body, { candidates: [{ name: 'Grenoble' }] }.to_json

    expected_url = "#{GoogleMapApi::BASE_URL}/place/findplacefromtext/json"
    expected_params = {
      params: {
        input: query,
        inputtype: 'textquery',
        fields: 'formatted_address,name,geometry',
        key: GoogleMapApi::GOOGLE_KEY
      }
    }

    RestClient.stub :get, mock_response, [expected_url, expected_params] do
      result = GoogleMapApi.places(query)
      assert_equal [{ 'name' => 'Grenoble' }], result
    end

    assert_mock mock_response
  end

  test 'places returns nil if API response code is not 200' do
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 500

    RestClient.stub :get, mock_response do
      result = GoogleMapApi.places('Grenoble')
      assert_nil result
    end

    assert_mock mock_response
  end

  test 'places returns false if an error occurs' do
    RestClient.stub :get, ->(_url, _params) { raise StandardError } do
      result = GoogleMapApi.places('Grenoble')
      assert_equal false, result
    end
  end

  test 'reverse_geocoding returns results when API call is successful' do
    lat = 45.1
    lng = 5.1

    mock_response = Minitest::Mock.new
    mock_response.expect :code, 200
    mock_response.expect :body, { results: [{ formatted_address: 'Grenoble' }] }.to_json

    expected_url = "#{GoogleMapApi::BASE_URL}/geocode/json"
    expected_params = {
      params: {
        latlng: "#{lat},#{lng}",
        key: GoogleMapApi::GOOGLE_KEY,
        result_type: 'locality|postal_code'
      }
    }

    RestClient.stub :get, mock_response, [expected_url, expected_params] do
      result = GoogleMapApi.reverse_geocoding(lat, lng)
      assert_equal [{ 'formatted_address' => 'Grenoble' }], result
    end

    assert_mock mock_response
  end

  test 'reverse_geocoding returns nil if API response code is not 200' do
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 401

    RestClient.stub :get, mock_response do
      result = GoogleMapApi.reverse_geocoding(45.1, 5.1)
      assert_nil result
    end

    assert_mock mock_response
  end

  test 'reverse_geocoding returns false if an error occurs' do
    RestClient.stub :get, ->(_url, _params) { raise StandardError } do
      result = GoogleMapApi.reverse_geocoding(45.1, 5.1)
      assert_equal false, result
    end
  end
end
