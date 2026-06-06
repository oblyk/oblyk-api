# frozen_string_literal: true

require 'test_helper'

class LocalityUserTest < ActiveSupport::TestCase
  setup do
    @locality_user = locality_users(:lu_jean_paris)
  end

  test 'locality user is valid' do
    assert @locality_user.valid?
  end

  test 'radius is set by default' do
    lu = LocalityUser.new(user: users(:normal_user), locality: localities(:locality_lyon))
    lu.valid?
    assert_equal 20, lu.radius
  end

  test 'radius must be between 1 and 100' do
    @locality_user.radius = 0
    assert @locality_user.invalid?
    @locality_user.radius = 101
    assert @locality_user.invalid?
    @locality_user.radius = 50
    assert @locality_user.valid?
  end

  test 'detail_to_json returns expected keys' do
    json = @locality_user.detail_to_json
    assert_equal @locality_user.id, json[:id]
    assert_equal @locality_user.user.id, json[:user][:id]
    assert_equal @locality_user.locality_id, json[:locality_id]
  end

  test 'update_locality! callback updates locality counts' do
    locality = @locality_user.locality
    locality.update_climber_counts!
    initial_count = locality.distinct_users_count

    LocalityUser.create!(user: users(:super_admin_user), locality: locality, partner_search: true)

    locality.reload
    assert_equal initial_count + 1, locality.distinct_users_count
  end

  test 'create_by_reverse_geocoding! creates locality and user locality' do
    LocalityUser.delete_all
    Locality.delete_all

    user = users(:normal_user)
    lu = LocalityUser.new(user: user, latitude: 48.8566, longitude: 2.3522)

    osm_mock = Minitest::Mock.new
    osm_mock.expect :call, {
      'address' => { 'city' => 'Paris', 'country_code' => 'fr', 'state' => 'Île-de-France' },
      'lat' => '48.8566',
      'lon' => '2.3522'
    }, [48.8566, 2.3522]

    OpenStreetMapApi.stub :reverse_geocoding, osm_mock do
      assert lu.create_by_reverse_geocoding!
      assert_equal 'Paris', lu.locality.name
      assert_equal user.id, lu.user_id
    end

    osm_mock.verify
  end
end
