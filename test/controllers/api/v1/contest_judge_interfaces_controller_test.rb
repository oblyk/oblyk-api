# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class ContestJudgeInterfacesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @contest = contests(:contest_1)
        @judge = contest_judges(:judge_1)
        @public_headers = api_access_token_headers
      end

      test 'should show judge interface data' do
        get api_v1_gym_contest_contest_judge_interface_url(@gym, @contest, @judge.uuid), headers: @public_headers, as: :json
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @judge.name, json_response['contest_judge']['name']
        assert_equal @contest.name, json_response['contest']['name']
      end

      test 'should unlock judge interface' do
        post unlock_api_v1_gym_contest_contest_judge_interface_url(@gym, @contest, @judge.uuid),
             params: {
               contest_judge: {
                 code: @judge.code
               }
             },
             headers: @public_headers,
             as: :json
        assert_response :success
        json_response = JSON.parse(response.body)
        assert json_response['unlocked']
        assert_not_nil json_response['token']
      end

      test 'should not unlock judge interface with wrong code' do
        post unlock_api_v1_gym_contest_contest_judge_interface_url(@gym, @contest, @judge.uuid),
             params: {
               contest_judge: {
                 code: 'WRONGCODE'
               }
             },
             headers: @public_headers,
             as: :json
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_not json_response['unlocked']
        assert_nil json_response['token']
      end

      test 'should get participants for judge' do
        exp = Time.zone.tomorrow.end_of_day.to_i
        token = JwtToken::Token.generate({ judge_id: @judge.id, code: @judge.code }, exp)

        headers = @public_headers.merge({ 'HttpContestJudgeToken' => token })

        get participants_api_v1_gym_contest_contest_judge_interface_url(@gym, @contest, @judge.uuid),
            headers: headers,
            as: :json
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
      end

      test 'should not get participants without token' do
        get participants_api_v1_gym_contest_contest_judge_interface_url(@gym, @contest, @judge.uuid),
            headers: @public_headers,
            as: :json
        assert_equal 419, response.status
      end
    end
  end
end
