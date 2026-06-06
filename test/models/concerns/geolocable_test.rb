# frozen_string_literal: true

require 'test_helper'

class GeolocableTest < ActiveSupport::TestCase
  setup do
    @crag = crags(:orpierre)
  end

  test 'validates latitude' do
    @crag.latitude = 91
    assert_not @crag.valid?
    @crag.latitude = -91
    assert_not @crag.valid?
    @crag.latitude = 45
    assert @crag.valid?
  end

  test 'validates longitude' do
    @crag.longitude = 181
    assert_not @crag.valid?
    @crag.longitude = -181
    assert_not @crag.valid?
    @crag.longitude = 5
    assert @crag.valid?
  end

  test 'geo_search returns objects within distance' do
    # Orpierre est à 44.319430, 5.697820
    results = Crag.geo_search(44.319, 5.697, 5)
    assert_includes results, @crag

    # Très loin
    results = Crag.geo_search(48.8566, 2.3522, 10) # Paris
    assert_not_includes results, @crag
  end
end
