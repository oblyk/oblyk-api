# frozen_string_literal: true

require 'test_helper'
require 'open-uri'

class HistorizeCragStaticMapJobTest < ActiveJob::TestCase
  setup do
    @crag = crags(:rocher_des_aures)
    @crag.save
    ENV['MAPBOX_STATIC_MAP_STYLE'] = 'test_style'
    ENV['MAPBOX_TOKEN'] = 'test_token'
  end

  test 'it attaches static maps to the crag' do
    # On s'assure que le crag n'a pas déjà de cartes
    @crag.static_map.purge if @crag.static_map.attached?
    @crag.static_map_banner.purge if @crag.static_map_banner.attached?
    @crag.reload

    mock_io = StringIO.new('fake-image-content')
    mock_io_banner = StringIO.new('fake-banner-content')

    calls = 0
    URI.stub :open, ->(_url) { (calls += 1) == 1 ? mock_io : mock_io_banner } do
      assert_difference 'ActiveStorage::Attachment.count', 2 do
        HistorizeCragStaticMapJob.perform_now(@crag.id)
      end
    end

    @crag.reload
    assert @crag.static_map.attached?
    assert @crag.static_map_banner.attached?
    assert_equal "rocher-des-aures-static-map.png", @crag.static_map.blob.filename.to_s
    assert_equal "rocher-des-aures-static-banner-map.png", @crag.static_map_banner.blob.filename.to_s
  end

  test 'it calls the correct mapbox urls' do
    expected_url = "https://api.mapbox.com/styles/v1/test_style/static/pin-l+2e3436(#{@crag.longitude},#{@crag.latitude})/#{@crag.longitude},#{@crag.latitude},15/1000x750?access_token=test_token"
    expected_banner_url = "https://api.mapbox.com/styles/v1/test_style/static/pin-l+2e3436(#{@crag.longitude},#{@crag.latitude})/#{@crag.longitude},#{@crag.latitude},11/1070x802?access_token=test_token"

    mock_io = StringIO.new('fake-image-content')
    mock_io_banner = StringIO.new('fake-banner-content')

    urls_called = []
    verify_urls = lambda do |url|
      urls_called << url
      [mock_io, mock_io_banner][urls_called.size - 1]
    end

    URI.stub :open, verify_urls do
      HistorizeCragStaticMapJob.perform_now(@crag.id)
    end

    assert_includes urls_called, expected_url
    assert_includes urls_called, expected_banner_url
    assert_equal 2, urls_called.size
  end

  test 'it raises error if crag does not exist' do
    assert_raises(ActiveRecord::RecordNotFound) do
      HistorizeCragStaticMapJob.perform_now(0)
    end
  end
end
