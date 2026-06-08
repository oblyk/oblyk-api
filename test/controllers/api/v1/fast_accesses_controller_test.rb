# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class FastAccessesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = users(:normal_user)
        @user_headers = api_headers(user: :normal_user)
        @public_headers = api_access_token_headers
      end

      test 'should get index' do
        get api_v1_fast_accesses_url, headers: @user_headers, as: :json
        assert_response :success

        json_response = JSON.parse(response.body)
        assert_includes json_response, 'follows_count'
        assert_includes json_response, 'contests'
      end

      test 'should be protected by session' do
        get api_v1_fast_accesses_url, headers: @public_headers, as: :json
        assert_response :unauthorized
      end

      test 'should return followed crag and gym' do
        crag = crags(:rocher_des_aures)
        gym = gyms(:my_gym)

        Follow.create!(user: @user, followable: crag)
        Follow.create!(user: @user, followable: gym)

        get api_v1_fast_accesses_url, headers: @user_headers, as: :json
        assert_response :success

        json_response = JSON.parse(response.body)
        assert_not_nil json_response['crag']
        assert_equal crag.name, json_response['crag']['name']
        assert_not_nil json_response['gym']
        assert_equal gym.name, json_response['gym']['name']
      end

      test 'should return active contests participation' do
        contest = contests(:contest_1)
        category = contest_categories(:category_senior)

        contest.update_columns(
          subscription_start_date: Date.current - 1.day,
          subscription_end_date: Date.current + 1.day,
          end_date: Date.current + 1.day
        )

        participant = ContestParticipant.new(
          user: @user,
          contest_category: category,
          first_name: @user.first_name,
          last_name: @user.last_name,
          date_of_birth: '1990-01-01',
          genre: 'male',
          email: @user.email,
          token: 'test-token'
        )

        participant.stub :send_subscription_mail, nil do
          participant.save(validate: false)
        end

        get api_v1_fast_accesses_url, headers: @user_headers, as: :json
        assert_response :success

        json_response = JSON.parse(response.body)
        assert_not_empty json_response['contests']
        assert_equal contest.name, json_response['contests'].first['name']
        assert_not_nil json_response['contests'].first['participant_token']
      end
    end
  end
end
