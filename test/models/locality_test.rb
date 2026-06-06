# frozen_string_literal: true

require 'test_helper'

class LocalityTest < ActiveSupport::TestCase
  setup do
    @locality = localities(:locality_paris)
  end

  test 'locality is valid' do
    assert @locality.valid?
  end

  test 'locality is invalid without name' do
    @locality.name = nil
    assert @locality.invalid?
  end

  test 'summary_to_json returns expected keys' do
    json = @locality.summary_to_json
    assert_equal @locality.id, json[:id]
    assert_equal @locality.name, json[:name]
    assert_equal @locality.code_country, json[:code_country]
  end

  test 'to_geo_json returns GeoJSON format' do
    geo_json = @locality.to_geo_json
    assert_equal 'Feature', geo_json[:type]
    assert_equal 'Point', geo_json[:geometry][:type]
    assert_equal @locality.longitude.to_f, geo_json[:geometry][:coordinates][0]
    assert_equal @locality.latitude.to_f, geo_json[:geometry][:coordinates][1]
  end

  test 'update_climber_counts! updates counts correctly' do
    @locality.locality_users.destroy_all
    @locality.reload

    user = users(:normal_user)
    user.update(last_activity_at: Time.current, partner_search: true)

    @locality.locality_users.create!(user: user, partner_search: true, local_sharing: true)

    @locality.update_climber_counts!
    @locality.reload

    assert_equal 1, @locality.partner_search_users_count
    assert_equal 1, @locality.local_sharing_users_count
    assert_equal 1, @locality.distinct_users_count
  end

  test 'scopes filter correctly' do
    @locality.update(partner_search_users_count: 5, local_sharing_users_count: 0)
    lyon = localities(:locality_lyon)
    lyon.update(partner_search_users_count: 0, local_sharing_users_count: 3)

    assert_includes Locality.with_partner_search, @locality
    assert_not_includes Locality.with_partner_search, lyon

    assert_includes Locality.with_local_sharing, lyon
    assert_not_includes Locality.with_local_sharing, @locality

    assert_includes Locality.with_climbers, @locality
    assert_includes Locality.with_climbers, lyon
  end
end
