# frozen_string_literal: true

require 'test_helper'

class GymTest < ActiveSupport::TestCase
  setup do
    @gym = gyms(:my_gym)
  end

  test 'gym is valid' do
    assert @gym.valid?
  end

  test 'gym is invalid without name' do
    @gym.name = nil
    assert_not @gym.valid?
  end

  test 'gym is invalid without latitude' do
    @gym.latitude = nil
    assert_not @gym.valid?
  end

  test 'gym is invalid without longitude' do
    @gym.longitude = nil
    assert_not @gym.valid?
  end

  test 'gym is invalid without address' do
    @gym.address = nil
    assert_not @gym.valid?
  end

  test 'gym is invalid without country' do
    @gym.country = nil
    assert_not @gym.valid?
  end

  test 'gym is invalid without city' do
    @gym.city = nil
    assert_not @gym.valid?
  end

  test 'gym location returns latitude and longitude' do
    assert_equal [45.0, 5.0], @gym.location
  end

  test 'gym app_path returns correct path' do
    assert_equal "/gyms/#{@gym.id}/#{@gym.slug_name}", @gym.app_path
  end

  test 'gym summary_to_json returns correct keys' do
    summary = @gym.summary_to_json
    assert_equal @gym.id, summary[:id]
    assert_equal @gym.name, summary[:name]
    assert_includes summary.keys, :attachments
  end
end
