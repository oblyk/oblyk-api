# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApiController
      before_action :set_user
      before_action :protected_private_profile

      def show; end

      private

      def protected_private_profile
        return if @user.public_profile
        return if login?

        render json: {}, status: :unauthorized
      end

      def set_user
        @user = User.find_by uuid: params[:id]
      end
    end
  end
end
