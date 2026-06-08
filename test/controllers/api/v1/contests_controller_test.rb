# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class ContestsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @gym.update_column(:assigned_at, Time.current)
        @contest = contests(:contest_1)
        @ongoing_contest = contests(:contest_ongoing)
        @finished_contest = contests(:contest_finished)

        @user = users(:normal_user)
        @admin = users(:super_admin_user)

        @public_headers = api_access_token_headers
        @user_headers = api_headers(user: :normal_user)
        @admin_headers = api_headers(user: :super_admin_user)
      end

      test 'should get opens' do
        get opens_api_v1_contests_url, headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert json_response.key?('is_coming')
        assert json_response.key?('ongoing')
        assert json_response.key?('past')
      end

      test 'should get index' do
        get api_v1_gym_contests_url(@gym), headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
      end

      test 'should get index with active filter' do
        get api_v1_gym_contests_url(@gym), params: { active: 'true' }, headers: @public_headers
        assert_response :success
      end

      test 'should show contest' do
        get api_v1_gym_contest_url(@gym, @contest), headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @contest.name, json_response['name']
      end

      test 'should get time_line' do
        get time_line_api_v1_gym_contest_url(@gym, @contest), headers: @admin_headers
        assert_response :success
      end

      test 'should not get time_line for non admin' do
        # On utilise un utilisateur qui n'a pas de compte (pas de token valide)
        get time_line_api_v1_gym_contest_url(@gym, @contest), headers: @public_headers
        assert_response :unauthorized
      end

      test 'should add banner' do
        dummy_file = fixture_file_upload('test/fixtures/files/image.jpg', 'image/jpeg')

        post add_banner_api_v1_gym_contest_url(@gym, @contest),
             params: { contest: { banner: dummy_file } },
             headers: @admin_headers
        assert_response :success
      end

      test 'should get results' do
        get results_api_v1_gym_contest_url(@gym, @ongoing_contest), headers: @public_headers
        assert_response :success
      end

      test 'should get statistics' do
        get statistics_api_v1_gym_contest_url(@gym, @contest), headers: @admin_headers
        assert_response :success
      end

      test 'should create contest' do
        assert_difference('Contest.count') do
          post api_v1_gym_contests_url(@gym),
               params: {
                 contest: {
                   name: 'New Contest',
                   start_date: Date.current + 1.month,
                   end_date: Date.current + 1.month,
                   subscription_start_date: Date.current,
                   subscription_end_date: Date.current + 2.weeks,
                   categorization_type: 'official_under_age'
                 }
               },
               headers: @admin_headers,
               as: :json
        end
        assert_response :success
      end

      test 'should update contest' do
        put api_v1_gym_contest_url(@gym, @contest),
            params: { contest: { name: 'Updated Contest Name' } },
            headers: @admin_headers,
            as: :json
        assert_response :success
        @contest.reload
        assert_equal 'Updated Contest Name', @contest.name
      end

      test 'should destroy draft contest' do
        @contest.update(draft: true)
        assert_difference('Contest.count', -1) do
          delete api_v1_gym_contest_url(@gym, @contest), headers: @admin_headers, as: :json
        end
        assert_response :success
      end

      test 'should not destroy published contest' do
        assert_no_difference('Contest.count') do
          delete api_v1_gym_contest_url(@gym, @contest), headers: @admin_headers, as: :json
        end
        assert_response :unprocessable_entity
      end

      test 'should update draft status' do
        put draft_api_v1_gym_contest_url(@gym, @contest),
            params: { contest: { draft: true } },
            headers: @admin_headers,
            as: :json
        assert_response :no_content
        @contest.reload
        assert @contest.draft
      end

      test 'should archive contest' do
        put archived_api_v1_gym_contest_url(@gym, @contest), headers: @admin_headers, as: :json
        assert_response :success
        @contest.reload
        assert_not_nil @contest.archived_at
      end

      test 'should unarchive contest' do
        @contest.archive!
        put unarchived_api_v1_gym_contest_url(@gym, @contest), headers: @admin_headers, as: :json
        assert_response :success
        @contest.reload
        assert_nil @contest.archived_at
      end
    end
  end
end
