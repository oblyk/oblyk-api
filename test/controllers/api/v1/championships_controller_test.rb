# frozen_string_literal: true

require 'test_helper'

class Api::V1::ChampionshipsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @gym = gyms(:my_gym)
    @championship = championships(:championship_1)
    @user = users(:super_admin_user)
    @auth_headers = api_headers(user: :super_admin_user)
  end

  test 'should get index' do
    get api_v1_gym_championships_url(gym_id: @gym.id), headers: @auth_headers, as: :json
    assert_response :success
  end

  test 'should show championship' do
    get api_v1_gym_championship_url(gym_id: @gym.id, id: @championship.id), headers: @auth_headers, as: :json
    assert_response :success
  end

  test 'should create championship' do
    assert_difference('Championship.count') do
      post api_v1_gym_championships_url(gym_id: @gym.id),
           params: { championship: { name: 'New Championship', combined_ranking_type: 'addition' } },
           headers: @auth_headers, as: :json
    end
    assert_response :success
  end

  test 'should update championship' do
    patch api_v1_gym_championship_url(gym_id: @gym.id, id: @championship.id),
          params: { championship: { name: 'Updated Championship' } },
          headers: @auth_headers, as: :json
    assert_response :success
    @championship.reload
    assert_equal 'Updated Championship', @championship.name
  end

  test 'should destroy championship' do
    assert_difference('Championship.count', -1) do
      delete api_v1_gym_championship_url(gym_id: @gym.id, id: @championship.id), headers: @auth_headers, as: :json
    end
    assert_response :success
  end

  test 'should get available contests' do
    get available_contests_api_v1_gym_championship_url(gym_id: @gym.id, id: @championship.id), headers: @auth_headers, as: :json
    assert_response :success
  end

  test 'should get results' do
    get results_api_v1_gym_championship_url(gym_id: @gym.id, id: @championship.id), headers: @auth_headers, as: :json
    # results might be empty or content, both are ok as long as it's not 404/500
    assert_includes [200, 204], response.status
  end

  test 'should get contests' do
    get contests_api_v1_gym_championship_url(gym_id: @gym.id, id: @championship.id), headers: @auth_headers, as: :json
    assert_response :success
  end

  test 'should archive championship' do
    put archived_api_v1_gym_championship_url(gym_id: @gym.id, id: @championship.id), headers: @auth_headers, as: :json
    assert_response :success
    @championship.reload
    assert_not_nil @championship.archived_at
  end

  test 'should unarchive championship' do
    @championship.archive!
    put unarchived_api_v1_gym_championship_url(gym_id: @gym.id, id: @championship.id), headers: @auth_headers, as: :json
    assert_response :success
    @championship.reload
    assert_nil @championship.archived_at
  end
end
