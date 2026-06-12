# frozen_string_literal: true

require 'test_helper'

class GymSerializerTest < ActiveSupport::TestCase
  setup do
    @gym = gyms(:my_gym)
    @serializer = GymSerializer.new(@gym)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @gym.id, attributes['id']
    assert_equal @gym.name, attributes['name']
    assert_equal @gym.app_path, attributes['app_path']
    assert_equal @gym.app_first_spaces_path, attributes['app_first_spaces_path']
    assert_equal @gym.optimal_spaces_path, attributes['optimal_spaces_path']
    assert_equal @gym.description, attributes['description']
    assert_equal @gym.email, attributes['email']
    assert_equal @gym.phone_number, attributes['phone_number']
    assert_equal @gym.web_site, attributes['web_site']
    assert_equal @gym.latitude.to_f, attributes['latitude'].to_f
    assert_equal @gym.longitude.to_f, attributes['longitude'].to_f
    assert_equal @gym.code_country, attributes['code_country']
    assert_equal @gym.country, attributes['country']
    assert_equal @gym.city, attributes['city']
    assert_equal @gym.big_city, attributes['big_city']
    assert_equal @gym.region, attributes['region']
    assert_equal @gym.address, attributes['address']
    assert_equal @gym.postal_code, attributes['postal_code']
    assert_equal @gym.sport_climbing, attributes['sport_climbing']
    assert_equal @gym.bouldering, attributes['bouldering']
    assert_equal @gym.representation_type, attributes['representation_type']
    assert_equal @gym.gym_billing_account_id, attributes['gym_billing_account_id']
    assert_equal @gym.administered?, attributes['administered']
    assert_equal @gym.guide_book?, attributes['have_guide_book']
    assert_equal @gym.gym_spaces.size, attributes['gym_spaces_count']
  end

  test 'It contains relationships' do
    relationships = @serialization['data']['relationships']
    assert_not_nil relationships['gym_options']
  end
end
