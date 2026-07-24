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
          first_name: 'Test',
          last_name: 'Test',
          date_of_birth: '2000-01-01',
          genre: 'male',
          contest_category: contest_categories(:category_senior),
          email: 'test@test.com'
        )
        token_param = p.token.sub('.', '-')
        get participant_api_v1_gym_contest_contest_participant_url(@gym, @contest, token_param), headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 'Test', json_response['first_name']
      end

      test 'should return 404 if participant is not found by token' do
        get participant_api_v1_gym_contest_contest_participant_url(@gym, @contest, 'invalid-token'), headers: @public_headers
        assert_response :not_found
        assert_equal 'no_found', response.body
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

      test 'should create participant with a new team' do
        contest_with_team = contests(:contest_ongoing)
        assert_difference('ContestParticipant.count') do
          assert_difference('ContestTeam.count') do
            post api_v1_gym_contest_contest_participants_url(@gym, contest_with_team),
                 params: {
                   contest_participant: {
                     first_name: 'Team',
                     last_name: 'Member',
                     date_of_birth: '2000-01-01',
                     genre: 'male',
                     email: 'team@member.com',
                     contest_category_id: @category.id
                   },
                   contest_team: {
                     name: 'New Awesome Team'
                   }
                 },
                 headers: @admin_headers,
                 as: :json
          end
        end
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_not_nil json_response['contest_team_id']
        assert_equal 'New Awesome Team', ContestTeam.find(json_response['contest_team_id']).name
      end

      test 'should create participant with an existing team name' do
        contest_with_team = contests(:contest_ongoing)
        existing_team = ContestTeam.create!(contest: contest_with_team, name: 'Existing Team')

        assert_difference('ContestParticipant.count') do
          assert_no_difference('ContestTeam.count') do
            post api_v1_gym_contest_contest_participants_url(@gym, contest_with_team),
                 params: {
                   contest_participant: {
                     first_name: 'Team',
                     last_name: 'Member 2',
                     date_of_birth: '2000-01-01',
                     genre: 'female',
                     email: 'team2@member.com',
                     contest_category_id: @category.id
                   },
                   contest_team: {
                     name: 'Existing Team'
                   }
                 },
                 headers: @admin_headers,
                 as: :json
          end
        end
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal existing_team.id, json_response['contest_team_id']
      end

      test 'should not create participant if team creation fails' do
        contest_with_team = contests(:contest_ongoing)
        post api_v1_gym_contest_contest_participants_url(@gym, contest_with_team),
             params: {
               contest_participant: {
                 first_name: 'Team',
                 last_name: 'Member 3',
                 date_of_birth: '2000-01-01',
                 genre: 'male',
                 email: 'team3@member.com',
                 contest_category_id: @category.id
               },
               contest_team: {
                 name: ''
               }
             },
             headers: @admin_headers,
             as: :json
        assert_response :unprocessable_content
      end

      test 'should not create participant as user' do
        other_user = User.create!(
          first_name: 'Other', last_name: 'User', email: "other-#{SecureRandom.hex}@user.com",
          password: 'Password123!', slug_name: "other-user-#{SecureRandom.hex}", uuid: SecureRandom.uuid
        )
        other_headers = api_headers(user: :gym_route_setter_user).merge('Authorization' => generate_token(other_user))

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

      test 'should return unprocessable content if creation fails' do
        post api_v1_gym_contest_contest_participants_url(@gym, @contest),
             params: {
               contest_participant: {
                 first_name: '',
                 last_name: 'Participant',
                 date_of_birth: '2000-01-01',
                 genre: 'male',
                 email: 'new@participant.com',
                 contest_category_id: @category.id
               }
             },
             headers: @admin_headers,
             as: :json
        assert_response :unprocessable_content
      end

      test 'should return unprocessable content if update fails' do
        put api_v1_gym_contest_contest_participant_url(@gym, @contest, @participant),
            params: { contest_participant: { first_name: '' } },
            headers: @admin_headers,
            as: :json
        assert_response :unprocessable_content
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

      test 'should import participants' do
        assert_difference('ContestParticipant.count', 2) do
          post import_api_v1_gym_contest_contest_participants_url(@gym, @contest),
               params: {
                 contest_participant: {
                   file: fixture_file_upload('participants.csv', 'text/csv'),
                   send_email: 'false'
                 }
               },
               headers: @admin_headers
        end

        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 2, json_response['created_count']
        assert_equal 0, json_response['errors_count']
      end

      test 'should not import participants with wrong file format' do
        post import_api_v1_gym_contest_contest_participants_url(@gym, @contest),
             params: {
               contest_participant: {
                 file: fixture_file_upload('image.jpg', 'image/jpeg')
               }
             },
             headers: @admin_headers
        assert_response :unprocessable_content
      end

      test 'should handle import errors' do
        @category.update_column(:waveable, true)

        post import_api_v1_gym_contest_contest_participants_url(@gym, @contest),
             params: {
               contest_participant: {
                 file: fixture_file_upload('participants_errors.csv', 'text/csv'),
                 send_email: 'false'
               }
             },
             headers: @admin_headers

        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 0, json_response['created_count']
        assert_equal 4, json_response['errors_count']
      end

      test 'should skip already imported participants' do
        ContestParticipant.create!(
          first_name: 'John', last_name: 'Doe', date_of_birth: '1990-01-01',
          genre: 'male', contest_category: @category, email: 'john@doe.com',
          contest: @contest
        )

        assert_difference('ContestParticipant.count', 1) do
          post import_api_v1_gym_contest_contest_participants_url(@gym, @contest),
               params: {
                 contest_participant: {
                   file: fixture_file_upload('participants.csv', 'text/csv'),
                   send_email: 'false'
                 }
               },
               headers: @admin_headers
        end

        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 1, json_response['created_count']
        assert_equal 1, json_response['already_imported_count']
      end
    end
  end
end
