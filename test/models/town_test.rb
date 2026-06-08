# frozen_string_literal: true

require 'test_helper'

class TownTest < ActiveSupport::TestCase
  setup do
    @town = towns(:valence)
  end

  test 'town is valid' do
    assert @town.valid?
  end

  test 'default_dist depends on population' do
    @town.population = 5000
    assert_equal 10, @town.default_dist

    @town.population = 15_000
    assert_equal 15, @town.default_dist

    @town.population = 35_000
    assert_equal 20, @town.default_dist

    @town.population = 60_000
    assert_equal 30, @town.default_dist
  end

  test 'town has town_json_objects' do
    assert_respond_to @town, :town_json_objects
    assert_includes @town.town_json_objects, town_json_objects(:valence_json)
  end

  test 'summary_to_json returns correct structure' do
    json = @town.summary_to_json
    assert_equal @town.id, json[:id]
    assert_equal @town.name, json[:name]
    assert_equal @town.slug_name, json[:slug_name]
    assert_equal @town.latitude.to_f, json[:latitude].to_f
    assert_equal @town.longitude.to_f, json[:longitude].to_f
    assert_equal @town.town_code, json[:town_code]
    assert_equal @town.zipcode, json[:zipcode]
    assert_not_nil json[:department]
  end

  test 'detail_to_json returns a hash with crags and gyms' do
    json = @town.detail_to_json(20)
    assert_equal 20, json[:dist]
    assert json.key?(:crags)
    assert json.key?(:gyms)
    assert json.key?(:guide_book_papers)
  end

  test 'historize! creates or updates a TownJsonObject' do
    assert_difference 'TownJsonObject.count', 0 do
      @town.historize!
    end

    beaufort = towns(:beaufort)
    assert_difference 'TownJsonObject.count', 1 do
      beaufort.historize!
    end

    town_json = TownJsonObject.find_by(town: beaufort)
    assert_not_nil town_json
    assert_equal beaufort.default_dist, town_json.dist
  end
end
