# frozen_string_literal: true

require 'test_helper'

class Api::V1::ChampionshipCategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @gym = gyms(:my_gym)
    @championship = championships(:championship_1)
    @category = championship_categories(:cat_championship_senior)
    @contest_category = contest_categories(:category_senior)
    @auth_headers = api_headers(user: :super_admin_user)
  end

  test 'should get index' do
    get api_v1_gym_championship_championship_categories_url(gym_id: @gym.id, championship_id: @championship.id),
        headers: @auth_headers, as: :json
    assert_response :success
  end

  test 'should show championship category' do
    get api_v1_gym_championship_championship_category_url(gym_id: @gym.id, championship_id: @championship.id, id: @category.id),
        headers: @auth_headers, as: :json
    assert_response :success
  end

  test 'should get contest categories' do
    get contest_categories_api_v1_gym_championship_championship_categories_url(gym_id: @gym.id, championship_id: @championship.id),
        headers: @auth_headers, as: :json
    assert_response :success
  end

  test 'should create championship category' do
    assert_difference('ChampionshipCategory.count') do
      post api_v1_gym_championship_championship_categories_url(gym_id: @gym.id, championship_id: @championship.id),
           params: { championship_category: { name: 'New Category', contest_categories: [@contest_category.id] } },
           headers: @auth_headers, as: :json
    end
    assert_response :no_content
  end

  test 'should destroy championship category' do
    assert_difference('ChampionshipCategory.count', -1) do
      delete api_v1_gym_championship_championship_category_url(gym_id: @gym.id, championship_id: @championship.id, id: @category.id),
             headers: @auth_headers, as: :json
    end
    assert_response :no_content
  end
end
