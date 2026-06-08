# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class ContestParticipantAscentsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @contest = contests(:contest_1)
        @participant = contest_participants(:participant_1)
        @contest_route = contest_routes(:route_1)
        @admin = users(:super_admin_user)
        
        @admin_headers = api_headers(user: :super_admin_user)
        @public_headers = api_access_token_headers
      end

      test 'should get index' do
        get api_v1_gym_contest_contest_participant_ascents_url(@gym, @contest),
            headers: @admin_headers
        assert_response :success
      end

      test 'should create contest_participant_ascent' do
        @participant.contest_participant_ascents.destroy_all
        assert_difference('ContestParticipantAscent.count') do
          post api_v1_gym_contest_contest_participant_contest_participant_ascents_url(@gym, @contest, @participant),
               params: {
                 contest_participant_ascent: {
                   contest_participant_token: @participant.token,
                   contest_route_id: @contest_route.id,
                   realised: true,
                   top_attempt: 1
                 }
               },
               headers: @public_headers,
               as: :json
        end
        assert_response :no_content
      end

      test 'should bulk create contest_participant_ascents' do
        @participant.contest_participant_ascents.destroy_all
        contest_route_2 = contest_routes(:route_2)
        assert_difference('ContestParticipantAscent.count', 2) do
          post bulk_api_v1_gym_contest_contest_participant_contest_participant_ascents_url(@gym, @contest, @participant),
               params: {
                 contest_participant_ascent: {
                   contest_participant_token: @participant.token,
                   ascents: [
                     { contest_route_id: @contest_route.id, realised: true, top_attempt: 1 },
                     { contest_route_id: contest_route_2.id, realised: true, top_attempt: 2 }
                   ]
                 }
               },
               headers: @public_headers,
               as: :json
        end
        assert_response :no_content
      end
    end
  end
end
