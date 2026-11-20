# frozen_string_literal: true

require "test_helper"

module Api
  module V1
    class ApiControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = users(:normal_user)
        @headers = api_access_token_headers
      end

      test "public request without authorization does not set current user id" do
        user_ids = get_crags_and_track_current_user_id(@headers)

        assert_response :success
        assert_empty user_ids
      end

      test "valid authorization sets current user id" do
        headers = @headers.merge("Authorization" => generate_token(@user))

        user_ids = get_crags_and_track_current_user_id(headers)

        assert_response :success
        assert_equal [ @user.id ], user_ids
      end

      test "expired authorization leaves public request anonymous" do
        token = JwtToken::Token.generate({ "id" => @user.id }, Time.now.to_i - 60)
        headers = @headers.merge("Authorization" => token)

        user_ids = get_crags_and_track_current_user_id(headers)

        assert_response :success
        assert_empty user_ids
      end

      test "authorization without a token leaves public request anonymous" do
        headers = @headers.merge("Authorization" => "Bearer")

        user_ids = get_crags_and_track_current_user_id(headers)

        assert_response :success
        assert_empty user_ids
      end

      test "authorization signed with another secret leaves public request anonymous" do
        token = JWT.encode({ data: { id: @user.id }, exp: Time.now.to_i + 60 }, "invalid-secret")
        headers = @headers.merge("Authorization" => "Bearer #{token}")

        user_ids = get_crags_and_track_current_user_id(headers)

        assert_response :success
        assert_empty user_ids
      end

      private

      def get_crags_and_track_current_user_id(headers)
        user_ids = []
        Current.stub(:user_id=, ->(user_id) { user_ids << user_id }) do
          get api_v1_crags_url, headers: headers
        end
        user_ids
      end
    end
  end
end
