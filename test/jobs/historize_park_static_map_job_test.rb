# frozen_string_literal: true

require 'test_helper'
require 'open-uri'

class HistorizeParkStaticMapJobTest < ActiveJob::TestCase
  setup do
    @park = parks(:park_one)
    ENV['MAPBOX_STATIC_MAP_STYLE'] = 'test_style'
    ENV['MAPBOX_TOKEN'] = 'test_token'
  end

  test 'it attaches a static map to the park' do
    @park.static_map.purge if @park.static_map.attached?
    @park.reload

    mock_io = StringIO.new('fake-image-content')

    URI.stub :open, mock_io do
      assert_difference 'ActiveStorage::Attachment.count', 1 do
        HistorizeParkStaticMapJob.perform_now(@park.id)
      end
    end

    @park.reload
    assert @park.static_map.attached?
    assert_equal "#{@park.id}-static-park-map.png", @park.static_map.blob.filename.to_s
  end

  test 'it calls the correct mapbox url' do
    expected_url = "https://api.mapbox.com/styles/v1/test_style/static/pin-l+2e3436(#{@park.longitude},#{@park.latitude})/#{@park.longitude},#{@park.latitude},13/200x200?access_token=test_token"

    mock_io = StringIO.new('fake-image-content')

    verify_url = lambda do |url|
      assert_equal expected_url, url
      mock_io
    end

    URI.stub :open, verify_url do
      HistorizeParkStaticMapJob.perform_now(@park.id)
    end
  end

  test 'it raises error if park does not exist' do
    assert_raises(ActiveRecord::RecordNotFound) do
      HistorizeParkStaticMapJob.perform_now(0)
    end
  end
end
