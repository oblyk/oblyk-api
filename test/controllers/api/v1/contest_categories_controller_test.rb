# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class ContestCategoriesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @gym.update_column(:assigned_at, Time.current)
        @contest = contests(:contest_1)
        @category = contest_categories(:category_u16)
        
        @admin_headers = api_headers(user: :super_admin_user)
        @user_headers = api_headers(user: :gym_route_setter_user)
        @public_headers = api_access_token_headers
      end

      test 'should get index' do
        get api_v1_gym_contest_contest_categories_url(@gym, @contest), headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
      end

      test 'should show contest category' do
        get api_v1_gym_contest_contest_category_url(@gym, @contest, @category), headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @category.name, json_response['name']
      end

      test 'should create contest category' do
        assert_difference('ContestCategory.count') do
          post api_v1_gym_contest_contest_categories_url(@gym, @contest),
               params: {
                 contest_category: {
                   name: 'New Category',
                   order: 5,
                   capacity: 50,
                   registration_obligation: 'u16'
                 }
               },
               headers: @admin_headers,
               as: :json
        end
        assert_response :success
      end

      test 'should update contest category' do
        put api_v1_gym_contest_contest_category_url(@gym, @contest, @category),
            params: { contest_category: { name: 'Updated Category Name' } },
            headers: @admin_headers,
            as: :json
        assert_response :success
        @category.reload
        assert_equal 'Updated Category Name', @category.name
      end

      test 'should destroy contest category' do
        category = ContestCategory.create!(
          name: 'To Destroy',
          contest: @contest,
          order: 10,
          registration_obligation: 'u16'
        )
        assert_difference('ContestCategory.count', -1) do
          delete api_v1_gym_contest_contest_category_url(@gym, @contest, category), headers: @admin_headers, as: :json
        end
        assert_response :success
      end

      test 'should not create contest category for non admin' do
        assert_no_difference('ContestCategory.count') do
          post api_v1_gym_contest_contest_categories_url(@gym, @contest),
               params: {
                 contest_category: {
                   name: 'New Category'
                 }
               },
               headers: @user_headers,
               as: :json
        end
        assert_response :forbidden
      end
    end
  end
end
