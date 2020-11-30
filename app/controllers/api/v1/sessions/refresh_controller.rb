# frozen_string_literal: true

module Api
  module V1
    module Sessions
      class RefreshController < ApiController
        before_action :authorize_refresh_by_access_request!

        def create
          session = JWTSessions::Session.new(payload: claimless_payload, refresh_by_access_allowed: true)
          tokens = session.refresh_by_access_payload do
            raise JWTSessions::Errors::Unauthorized, 'Somethings not right here!'
          end
          response.set_cookie(
            JWTSessions.access_cookie,
            value: tokens[:access],
            httponly: true,
            secure: Rails.env.production?
          )
          render json: { csrf: tokens[:csrf] }
        end
      end
    end
  end
end
