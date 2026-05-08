# frozen_string_literal: true

require 'test_helper'

class OpenStreetMapApiTest < ActiveSupport::TestCase
  test 'search returns parsed JSON on success' do
    query = 'Grenoble'
    response_body = [{ 'lat' => '45.1875602', 'lon' => '5.7357819', 'display_name' => 'Grenoble, Isère, France' }].to_json
    
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 200
    mock_response.expect :body, response_body

    expected_params = {
      params: {
        q: query,
        format: 'json',
        addressdetails: 1,
        email: OpenStreetMapApi::EMAIL
      }
    }

    RestClient.stub :get, ->(url, options) {
      assert_equal "#{OpenStreetMapApi::BASE_URL}/search", url
      assert_equal expected_params, options
      mock_response
    } do
      result = OpenStreetMapApi.search(query)
      assert_equal 'Grenoble, Isère, France', result.first['display_name']
    end
  end

  test 'search returns nil when code is not 200' do
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 404

    RestClient.stub :get, mock_response do
      assert_nil OpenStreetMapApi.search('Unknown')
    end
  end

  test 'search returns false when an error occurs' do
    RestClient.stub :get, ->(_url, _params) { raise StandardError } do
      assert_equal false, OpenStreetMapApi.search('Error')
    end
  end

  test 'reverse_geocoding returns parsed JSON on success' do
    lat = 45.1875602
    lon = 5.7357819
    response_body = { 'address' => { 'city' => 'Grenoble' } }.to_json

    mock_response = Minitest::Mock.new
    mock_response.expect :code, 200
    mock_response.expect :body, response_body

    expected_params = {
      params: {
        format: 'json',
        lat: lat,
        lon: lon,
        zoom: 13,
        addressdetails: 1,
        email: OpenStreetMapApi::EMAIL
      }
    }

    RestClient.stub :get, ->(url, options) {
      assert_equal "#{OpenStreetMapApi::BASE_URL}/reverse", url
      assert_equal expected_params, options
      mock_response
    } do
      result = OpenStreetMapApi.reverse_geocoding(lat, lon)
      assert_equal 'Grenoble', result['address']['city']
    end
  end

  test 'reverse_geocoding returns nil when code is not 200' do
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 500

    RestClient.stub :get, mock_response do
      assert_nil OpenStreetMapApi.reverse_geocoding(0, 0)
    end
  end

  test 'reverse_geocoding returns false when an error occurs' do
    RestClient.stub :get, ->(_url, _params) { raise StandardError } do
      assert_equal false, OpenStreetMapApi.reverse_geocoding(0, 0)
    end
  end
end
