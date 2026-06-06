# frozen_string_literal: true

require 'test_helper'

class ClimberProximityTest < ActiveSupport::TestCase
  setup do
    @user = users(:normal_user)
    @other_user = users(:super_admin_user)
    @proximity = ClimberProximity.new(@user)

    Ascent.delete_all
    Follow.delete_all
  end

  test 'initializes with a user' do
    assert_equal @user, @proximity.user
  end

  test 'returns users with proximity points from common crag ascents' do
    route = crag_routes(:route_one)
    today = Date.current

    Ascent.create!(user: @user, crag_route: route, released_at: today, ascent_status: 'sent')
    Ascent.create!(user: @other_user, crag_route: route, released_at: today, ascent_status: 'sent')

    results = @proximity.results
    match = results.find { |r| r[:id] == @other_user.id }

    assert_not_nil match
    assert match[:proximity][:ascent_crags] >= 1
    assert match[:proximity][:proximity_points] >= 1
  end

  test 'returns users with proximity points from common gym ascents' do
    gym = gyms(:my_gym)
    today = Date.current

    Ascent.create!(user: @user, gym_id: gym.id, released_at: today, ascent_status: 'sent')
    Ascent.create!(user: @other_user, gym_id: gym.id, released_at: today, ascent_status: 'sent')

    results = @proximity.results
    match = results.find { |r| r[:id] == @other_user.id }

    assert_not_nil match
    assert match[:proximity][:ascent_gyms] >= 1
    assert match[:proximity][:proximity_points] >= 1
  end

  test 'returns users with proximity points from common friends' do
    friend = User.new(
      first_name: 'Common',
      last_name: 'Friend',
      email: 'friend@test.com',
      password: 'password123',
      uuid: SecureRandom.uuid
    )
    friend.save(validate: false)

    # exclude oblyk_user_id: 57
    friend.update_column(:id, 100) if friend.id == 57

    Follow.create!(user: @user, followable: friend, accepted_at: Time.current)
    Follow.create!(user: @other_user, followable: friend, accepted_at: Time.current)

    results = @proximity.results
    match = results.find { |r| r[:id] == @other_user.id }

    assert_not_nil match
    assert_equal 1, match[:proximity][:common_friends]
    assert_equal 2, match[:proximity][:proximity_points]
  end

  test 'returns users with proximity points from followed crags' do
    crag = crags(:rocher_des_aures)

    Follow.create!(user: @user, followable: crag, accepted_at: Time.current)
    Follow.create!(user: @other_user, followable: crag, accepted_at: Time.current)

    results = @proximity.results
    match = results.find { |r| r[:id] == @other_user.id }

    assert_not_nil match
    assert_equal 1, match[:proximity][:followed_crags]
    assert_equal 0.1, match[:proximity][:proximity_points].to_f
  end

  test 'returns users with proximity points from followed gyms' do
    gym = gyms(:my_gym)

    Follow.create!(user: @user, followable: gym, accepted_at: Time.current)
    Follow.create!(user: @other_user, followable: gym, accepted_at: Time.current)

    results = @proximity.results
    match = results.find { |r| r[:id] == @other_user.id }

    assert_not_nil match
    assert_equal 1, match[:proximity][:followed_gyms]
    assert_equal 0.1, match[:proximity][:proximity_points].to_f
  end

  test 'excludes users already followed' do
    crag = crags(:rocher_des_aures)
    Follow.create!(user: @user, followable: crag, accepted_at: Time.current)
    Follow.create!(user: @other_user, followable: crag, accepted_at: Time.current)

    assert @proximity.results.any? { |r| r[:id] == @other_user.id }

    Follow.create!(user: @user, followable: @other_user, accepted_at: Time.current)

    assert_not @proximity.results.any? { |r| r[:id] == @other_user.id }
  end

  test 'respects limit and offset' do
    3.times do |i|
      u = User.new(
        first_name: "User#{i}",
        last_name: "Test",
        email: "user#{i}@test.com",
        password: "password123",
        uuid: SecureRandom.uuid
      )
      u.save(validate: false)
      Follow.create!(user: u, followable: crags(:rocher_des_aures), accepted_at: Time.current)
    end
    Follow.create!(user: @user, followable: crags(:rocher_des_aures), accepted_at: Time.current)

    full_results = @proximity.results(per_page: 10)
    assert full_results.size >= 4

    paged_results = @proximity.results(page: 1, per_page: 2)
    assert_equal 2, paged_results.size

    paged_results_2 = @proximity.results(page: 2, per_page: 2)
    assert_equal 2, paged_results_2.size

    assert_not_equal paged_results.first[:id], paged_results_2.first[:id]
  end
end
