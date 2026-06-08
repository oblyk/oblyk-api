# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class FfmeContestsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @gym.update_column(:assigned_at, Time.current)
        @contest = contests(:contest_1)
        @ffme_contest = ffme_contests(:ffme_contest_1)

        @admin = users(:super_admin_user)
        @gym_admin = users(:gym_route_setter_user)

        ga = GymAdministrator.find_or_create_by!(gym: @gym, user: @gym_admin)
        ga.update!(roles: [GymRole::MANAGE_GYM])

        @admin_headers = api_headers(user: :super_admin_user)
        @gym_admin_headers = api_headers(user: :gym_route_setter_user)
        @user_headers = api_headers(user: :other_user)
      end

      test 'should show ffme contest' do
        get api_v1_gym_contest_ffme_contest_url(@gym, @contest, @ffme_contest),
            headers: @gym_admin_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @ffme_contest.name, json_response['name']
      end

      test 'should create ffme contest' do
        MyCompet.stub :create_contest, { 'idFFME' => 123 } do
          assert_difference('FfmeContest.count') do
            post api_v1_gym_contest_ffme_contests_url(@gym, @contest),
                 params: {
                   ffme_contest: {
                     name: 'Nouveau Championnat',
                     contact_email: 'test@ffme.fr',
                     contest_type: 'boulder',
                     start_date: Date.current,
                     end_date: Date.current
                   }
                 },
                 headers: @gym_admin_headers,
                 as: :json
          end
          assert_response :success
          json_response = JSON.parse(response.body)
          assert_equal 'create_on_my_compet', json_response['status']
        end
      end

      test 'should not create ffme contest with invalid params' do
        assert_no_difference('FfmeContest.count') do
          post api_v1_gym_contest_ffme_contests_url(@gym, @contest),
               params: {
                 ffme_contest: {
                   name: '',
                   contact_email: 'invalid'
                 }
               },
               headers: @gym_admin_headers,
               as: :json
        end
        assert_response :unprocessable_entity
      end

      test 'should update ffme contest' do
        MyCompet.stub :update_contest, true do
          put api_v1_gym_contest_ffme_contest_url(@gym, @contest, @ffme_contest),
              params: { ffme_contest: { name: 'Nom mis à jour' } },
              headers: @gym_admin_headers,
              as: :json
          assert_response :success
          @ffme_contest.reload
          assert_equal 'Nom mis à jour', @ffme_contest.name
        end
      end

      test 'should get link' do
        MyCompet.stub :link, { 'urlResultats' => 'http://mycompet.fr/results' } do
          get link_api_v1_gym_contest_ffme_contest_url(@gym, @contest, @ffme_contest),
              headers: @gym_admin_headers
          assert_response :success
          json_response = JSON.parse(response.body)
          assert_equal 'http://mycompet.fr/results', json_response['link']
        end
      end

      test 'should send results if sendable' do
        @ffme_contest.update(start_date: Date.yesterday, end_date: Date.tomorrow)

        MyCompet.stub :send_results, true do
          post send_results_api_v1_gym_contest_ffme_contest_url(@gym, @contest, @ffme_contest),
               headers: @gym_admin_headers
          assert_response :success
          @ffme_contest.reload
          assert_equal 'result_sent', @ffme_contest.status
          assert_not_nil @ffme_contest.results_send_at
        end
      end

      test 'should not send results if not sendable' do
        @ffme_contest.update(start_date: Date.tomorrow, end_date: Date.tomorrow + 1.day)

        post send_results_api_v1_gym_contest_ffme_contest_url(@gym, @contest, @ffme_contest),
             headers: @gym_admin_headers
        assert_response :unprocessable_entity
        json_response = JSON.parse(response.body)
        assert_equal 'ffme_contest_is_not_sendable', json_response['error']['base'].first
      end

      test 'should be protected by administrator' do
        get api_v1_gym_contest_ffme_contest_url(@gym, @contest, @ffme_contest),
            headers: @user_headers
        assert_response :unauthorized
      end
    end
  end
end
