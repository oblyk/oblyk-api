# frozen_string_literal: true

require "test_helper"

class HistorizeCragStaticMapJobTest < ActiveJob::TestCase
  setup do
    @crag = crags(:rocher_des_aures)

    @previous_style = ENV["MAPBOX_STATIC_MAP_STYLE"]
    @previous_token = ENV["MAPBOX_TOKEN"]
    ENV["MAPBOX_STATIC_MAP_STYLE"] = "mapbox/streets-v11"
    ENV["MAPBOX_TOKEN"] = "fake-token"
  end

  teardown do
    ENV["MAPBOX_STATIC_MAP_STYLE"] = @previous_style
    ENV["MAPBOX_TOKEN"] = @previous_token
  end

  def success_response
    response = Net::HTTPOK.new("1.1", "200", "OK")
    response.define_singleton_method(:body) { "fake-png-binary-data" }
    response
  end

  def failure_response
    Net::HTTPBadRequest.new("1.1", "400", "Bad Request")
  end

  test "loads the static map and the banner map when both requests are successful" do
    Net::HTTP.stub :get_response, success_response do
      HistorizeCragStaticMapJob.perform_now(@crag.id)
    end

    @crag.reload

    assert_predicate @crag.static_map, :attached?
    assert_equal "image/png", @crag.static_map.content_type
    assert_equal "#{@crag.slug_name}-static-map.png", @crag.static_map.filename.to_s

    assert_predicate @crag.static_map_banner, :attached?
    assert_equal "image/png", @crag.static_map_banner.content_type
    assert_equal "#{@crag.slug_name}-static-banner-map.png", @crag.static_map_banner.filename.to_s
  end

  test "constructs the two Mapbox URLs with the correct parameters (zoom level, size, coordinates)" do
    captured_uris = []

    Net::HTTP.stub :get_response, lambda { |uri|
      captured_uris << uri.to_s
      success_response
    } do
      HistorizeCragStaticMapJob.perform_now(@crag.id)
    end

    assert_equal 2, captured_uris.size

    static_map_url, banner_url = captured_uris

    assert_match(%r{\Ahttps://api\.mapbox\.com/styles/v1/mapbox/streets-v11/static/}, static_map_url)
    assert_includes static_map_url, "#{@crag.longitude},#{@crag.latitude},15/1000x750"
    assert_includes static_map_url, "access_token=fake-token"

    assert_match(%r{\Ahttps://api\.mapbox\.com/styles/v1/mapbox/streets-v11/static/}, banner_url)
    assert_includes banner_url, "#{@crag.longitude},#{@crag.latitude},11/1070x802"
    assert_includes banner_url, "access_token=fake-token"
  end

  test "raises an error and does not attach anything if the first call (static map) fails" do
    call_count = 0

    error = assert_raises(RuntimeError) do
      Net::HTTP.stub :get_response, lambda { |*|
        call_count += 1
        failure_response
      } do
        HistorizeCragStaticMapJob.perform_now(@crag.id)
      end
    end

    assert_match(/Failed to fetch map: 400/, error.message)
    assert_equal 1, call_count, "The second call (banner) must not be attempted"

    @crag.reload

    assert_not_predicate @crag.static_map, :attached?
    assert_not_predicate @crag.static_map_banner, :attached?
  end

  test "raises an error if the second call (banner map) fails; the static map remains attached" do
    responses = [success_response, failure_response]

    error = assert_raises(RuntimeError) do
      Net::HTTP.stub :get_response, lambda { |*|
        responses.shift
      } do
        HistorizeCragStaticMapJob.perform_now(@crag.id)
      end
    end

    assert_match(/Failed to fetch map: 400/, error.message)

    @crag.reload

    assert_predicate @crag.static_map, :attached?
    assert_not_predicate @crag.static_map_banner, :attached?
  end

  test "Return ActiveRecord::RecordNotFound if crag not exists" do
    Net::HTTP.stub :get_response, ->(*) { raise "crag doesn’t exist" } do
      assert_raises(ActiveRecord::RecordNotFound) do
        HistorizeCragStaticMapJob.perform_now(-1)
      end
    end
  end
end
