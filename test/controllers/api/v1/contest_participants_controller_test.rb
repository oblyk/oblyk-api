# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class ContestParticipantsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @contest = contests(:contest_1)
        @participant = contest_participants(:participant_1)
        @category = contest_categories(:category_senior)
        @wave = contest_waves(:wave_1)
        
        @user = users(:gym_route_setter_user)
        @admin = users(:super_admin_user)
        
        @public_headers = api_access_token_headers
        @user_headers = api_headers(user: :gym_route_setter_user)
        @admin_headers = api_headers(user: :super_admin_user)

        # Set host for mailer
        Rails.application.config.action_mailer.default_url_options = { host: 'http://localhost:3000' }
      end

      test 'should get index' do
        get api_v1_gym_contest_contest_participants_url(@gym, @contest), headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
      end

      test 'should show participant' do
        p = ContestParticipant.create!(
          first_name: 'Test', last_name: 'Test', date_of_birth: '2000-01-01', 
          genre: 'male', contest_category: contest_categories(:category_senior),
          email: 'test@test.com'
        )
        get api_v1_gym_contest_contest_participant_url(@gym, @contest, p), headers: @user_headers
        assert_response :success
      end

      test 'should get participant details' do
        p = ContestParticipant.create!(
          first_name: 'Test', last_name: 'Test', date_of_birth: '2000-01-01', 
          genre: 'male', contest_category: contest_categories(:category_senior),
          email: 'test@test.com'
        )
        token_param = p.token.sub('.', '-')
        get participant_api_v1_gym_contest_contest_participant_url(@gym, @contest, token_param), headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 'Test', json_response['first_name']
      end

      test 'should create participant as admin' do
        @contest.stub :team_contest, false do
          assert_difference('ContestParticipant.count') do
            post api_v1_gym_contest_contest_participants_url(@gym, @contest),
                 params: {
                   contest_participant: {
                     first_name: 'New',
                     last_name: 'Participant',
                     date_of_birth: '2000-01-01',
                     genre: 'male',
                     email: 'new@participant.com',
                     contest_category_id: @category.id
                   }
                 },
                 headers: @admin_headers,
                 as: :json
          end
        end
        assert_response :success
      end

      test 'should not create participant as user' do
        other_user = User.create!(
          first_name: 'Other', last_name: 'User', email: "other-#{SecureRandom.hex}@user.com", 
          password: 'Password123!', slug_name: "other-user-#{SecureRandom.hex}", uuid: SecureRandom.uuid
        )
        other_headers = api_headers(user: :gym_route_setter_user).merge('Authorization' => generate_token(other_user))
        
        # We need to make sure the gym is administered to trigger protected_by_administrator
        @gym.update_column(:assigned_at, Time.current)
        
        post api_v1_gym_contest_contest_participants_url(@gym, @contest),
             params: { 
               contest_participant: { 
                 first_name: 'New',
                 last_name: 'Part',
                 date_of_birth: '2000-01-01',
                 genre: 'male',
                 email: 'test@test.com',
                 contest_category_id: @category.id
               } 
             },
             headers: other_headers,
             as: :json
        assert_response :unauthorized
      end

      test 'should subscribe' do
        assert_difference('ContestParticipant.count') do
          post subscribe_api_v1_gym_contest_contest_participants_url(@gym, @contest),
               params: {
                 contest_participant: {
                   first_name: 'Subscriber',
                   last_name: 'Name',
                   date_of_birth: '1995-05-05',
                   genre: 'female',
                   email: 'subscriber@test.com',
                   contest_category_id: @category.id
                 }
               },
               headers: @public_headers,
               as: :json
        end
        assert_response :created
      end

      test 'should update participant as admin' do
        put api_v1_gym_contest_contest_participant_url(@gym, @contest, @participant),
            params: { contest_participant: { first_name: 'UpdatedName' } },
            headers: @admin_headers,
            as: :json
        assert_response :success
        @participant.reload
        assert_equal 'UpdatedName', @participant.first_name
      end

      test 'should destroy participant as admin' do
        assert_difference('ContestParticipant.count', -1) do
          delete api_v1_gym_contest_contest_participant_url(@gym, @contest, @participant), headers: @admin_headers, as: :json
        end
        assert_response :success
      end

      test 'should export participants' do
        get export_api_v1_gym_contest_contest_participants_url(@gym, @contest), headers: @admin_headers
        assert_response :success
        assert_equal 'text/csv', response.content_type
      end

      test 'should get import template' do
        get import_template_api_v1_gym_contest_contest_participants_url(@gym, @contest), headers: @admin_headers
        assert_response :success
        assert_equal 'text/csv', response.content_type
      end

      test 'should link to current user' do
        put link_to_current_user_api_v1_gym_contest_contest_participant_url(@gym, @contest, @participant), headers: @user_headers
        assert_response :no_content
        @participant.reload
        assert_equal @user.id, @participant.user_id
      end

      test 'should synchronise with ffme contest' do
        put synchronise_participant_with_ffme_contest_api_v1_gym_contest_contest_participant_url(@gym, @contest, @participant), headers: @user_headers
        assert_response :no_content
        @participant.reload
        assert @participant.synchronise_with_ffme_contest
      end

      test 'should get tombola winners' do
        get tombola_winners_api_v1_gym_contest_contest_participants_url(@gym, @contest), headers: @user_headers
        assert_response :success
      end

      test 'should launch tombola' do
        post tombola_api_v1_gym_contest_contest_participants_url(@gym, @contest),
             params: { type: 'launch', filters: {} },
             headers: @admin_headers,
             as: :json
        assert_response :success
      end
    end
  end
end
