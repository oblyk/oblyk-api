# frozen_string_literal: true

module Api
  module V1
    class ApiController < ApplicationController
      def user_for_paper_trail
        @current_user ? @current_user.id : 'Public user'
      end

      private

      def authorization_token
        request.headers['Authorization'].split(' ').last
      end

      def verify_json_web_token
        data = JwtToken::Token.decode(authorization_token)['data']
        @current_user ||= User.find data['id']
        User.current = @current_user
      rescue StandardError
        not_authorized
      end

      def login?
        data = JwtToken::Token.decode(authorization_token)['data']
        @current_user ||= User.find data['id']
        User.current = @current_user
        true
      rescue StandardError
        false
      end

      def not_authorized
        render json: { error: 'Not Authorized' }, status: :unauthorized
      end

      def protected_by_session
        verify_json_web_token
        set_paper_trail_whodunnit
      end

      def protected_by_super_admin
        protected_by_session
        not_authorized unless @current_user.super_admin
      end
    end
  end
end
