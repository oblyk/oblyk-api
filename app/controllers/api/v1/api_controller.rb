# frozen_string_literal: true

module Api
  module V1
    class ApiController < ApplicationController

      private

      def authorization_token
        request.headers['Authorization'].split(' ').last
      end

      def verify_json_web_token
        JwtToken::Token.decode(authorization_token)
      rescue StandardError
        render json: { auth: false }, status: :unauthorized
      end

      def session_data
        JwtToken::Token.decode(authorization_token)['data']
      end

      def current_user
        @current_user ||= User.find session_data['id']
      end

      def not_authorized
        render json: { error: 'Not Authorized' }, status: :unauthorized
      end

      def protected_by_session
        verify_json_web_token
        current_user
      end

      def protected_by_super_admin
        verify_json_web_token
        current_user
        not_authorized unless @current_user.super_admin
      end
    end
  end
end
