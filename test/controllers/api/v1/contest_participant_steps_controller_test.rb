# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class ContestParticipantStepsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @contest = contests(:contest_1)
        @participant = contest_participants(:participant_1)
        @step = contest_stage_steps(:step_1_stage_1)
        @admin = users(:super_admin_user)

        @admin_headers = api_headers(user: :super_admin_user)
      end

      test 'should subscribe participant to step' do
        @participant.contest_participant_steps.destroy_all
        assert_difference('ContestParticipantStep.count') do
          post subscribe_api_v1_gym_contest_contest_participant_steps_url(@gym, @contest),
               params: {
                 contest_participant_step: {
                   contest_participant_id: @participant.id,
                   contest_stage_step_id: @step.id,
                   subscribe: true
                 }
               },
               headers: @admin_headers,
               as: :json
        end
        assert_response :no_content
      end

      test 'should unsubscribe participant from step' do
        ContestParticipantStep.create(
          contest_participant: @participant,
          contest_stage_step: @step
        )
        assert_difference('ContestParticipantStep.count', -1) do
          post subscribe_api_v1_gym_contest_contest_participant_steps_url(@gym, @contest),
               params: {
                 contest_participant_step: {
                   contest_participant_id: @participant.id,
                   contest_stage_step_id: @step.id,
                   subscribe: false
                 }
               },
               headers: @admin_headers,
               as: :json
        end
        assert_response :no_content
      end
    end
  end
end
