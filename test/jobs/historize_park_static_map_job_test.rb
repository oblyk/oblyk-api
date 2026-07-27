# frozen_string_literal: true

require "test_helper"

class HistorizeParkStaticMapJobTest < ActiveJob::TestCase
  setup do
    @park = parks(:park_one)

    @previous_style = ENV["MAPBOX_STATIC_MAP_STYLE"]
    @previous_token = ENV["MAPBOX_TOKEN"]
    ENV["MAPBOX_STATIC_MAP_STYLE"] = "mapbox/streets-v11"
    ENV["MAPBOX_TOKEN"] = "fake-token"
  end

  teardown do
    ENV["MAPBOX_STATIC_MAP_STYLE"] = @previous_style
    ENV["MAPBOX_TOKEN"] = @previous_token
  end

  test "attaches the static map to the park when the request is successful" do
    fake_response = Net::HTTPOK.new("1.1", "200", "OK")
    fake_response.define_singleton_method(:body) { "fake-png-binary-data" }

    Net::HTTP.stub :get_response, fake_response do
      HistorizeParkStaticMapJob.perform_now(@park.id)
    end

    @park.reload

    assert_predicate @park.static_map, :attached?
    assert_equal "image/png", @park.static_map.content_type
    assert_equal "#{@park.id}-static-park-map.png", @park.static_map.filename.to_s
  end

  test "constructs the Mapbox URL using the park’s coordinates and the environment variables" do
    fake_response = Net::HTTPOK.new("1.1", "200", "OK")
    fake_response.define_singleton_method(:body) { "fake-png-binary-data" }

    captured_uri = nil
    Net::HTTP.stub :get_response, lambda { |uri|
      captured_uri = uri
      fake_response
    } do
      HistorizeParkStaticMapJob.perform_now(@park.id)
    end

    assert_match(%r{\Ahttps://api\.mapbox\.com/styles/v1/mapbox/streets-v11/static/}, captured_uri.to_s)
    assert_includes captured_uri.to_s, "#{@park.longitude},#{@park.latitude}"
    assert_includes captured_uri.to_s, "access_token=fake-token"
  end

  test "raises an error and does not attach anything if Mapbox returns a failure" do
    fake_response = Net::HTTPBadRequest.new("1.1", "400", "Bad Request")

    error = assert_raises(RuntimeError) do
      Net::HTTP.stub :get_response, fake_response do
        HistorizeParkStaticMapJob.perform_now(@park.id)
      end
    end

    assert_match(/Failed to fetch map: 400/, error.message)

    @park.reload

    assert_not_predicate @park.static_map, :attached?
  end

  test "raises ActiveRecord::RecordNotFound if the park does not exist" do
    Net::HTTP.stub :get_response, ->(*) { raise "should not be called" } do
      assert_raises(ActiveRecord::RecordNotFound) do
        HistorizeParkStaticMapJob.perform_now(-1)
      end
    end
  end
end
