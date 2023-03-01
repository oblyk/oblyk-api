# frozen_string_literal: true

module Api
  module V1
    class ApiController < ApplicationController
      before_action :check_ip
      before_action :check_honeypot_params
      before_action :set_current_organization

      def user_for_paper_trail
        @current_user ? @current_user.id : 'Public user'
      end

      private

      # Check if request ip isn't in ip black list
      def check_ip
        return unless request_can_write?

        blocked_ip = IpBlackList.currently_blocked.find_by ip: request.env['HTTP_X_REAL_IP']
        return if blocked_ip.blank?

        blocked_ip.blocked!(params)
        honeypot_response
      end

      # Check if honeypot params is sent
      def check_honeypot_params
        return unless request_can_write?

        honeypot_params = params.fetch(ENV['HONEYPOT_PARAMS'], false)
        return unless honeypot_params
        return if honeypot_params.blank?

        blocked_ip = IpBlackList.new ip: request.env['HTTP_X_REAL_IP']
        f = ActionDispatch::Http::ParameterFilter.new(Rails.application.config.filter_parameters)
        blocked_ip.blocked! f.filter(params)
        honeypot_response
      end

      # Set current organization by http api access token
      def set_current_organization
        Organization.current = Rails.cache.fetch("#{request.headers['HttpApiAccessToken']}/organization_cache", expires_in: 10.minutes) do
          Organization.find_by! api_access_token: request.headers['HttpApiAccessToken']
        end
      rescue StandardError
        forbidden
      end

      # Extract login (/authorization) token
      def authorization_token
        request.headers['Authorization'].split(' ').last
      end

      # Verify jwt and set current user
      def verify_json_web_token
        data = JwtToken::Token.decode(authorization_token)['data']
        @current_user ||= User.find data['id']
        User.current = @current_user
      rescue StandardError
        not_authorized
      end

      # Return if current user is connected
      def login?
        data = JwtToken::Token.decode(authorization_token)['data']
        @current_user ||= User.find data['id']
        User.current = @current_user
        true
      rescue StandardError
        false
      end

      # Standard not authorized response
      def not_authorized
        render json: { error: 'Not Authorized' }, status: :unauthorized
      end

      def forbidden
        render json: {
          error: 'You are not allowed to do this operation',
          code_error: 'not_allowed'
        }, status: :forbidden
      end

      # response for bot spammer
      def honeypot_response
        render json: { go_fly_a_kite: true }, status: :ok
      end

      # Return error unless active session
      def protected_by_session
        verify_json_web_token
        set_paper_trail_whodunnit
      end

      # Return error if current user is not a super admin
      def protected_by_super_admin
        protected_by_session
        forbidden unless @current_user.super_admin
      end

      # Return if a request tries to write
      def request_can_write?
        %w[PUT PATCH POST DELETE].include?(request.method)
      end
    end
  end
end
