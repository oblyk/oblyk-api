# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApiController
      before_action :set_user

      def show; end

      private

      def set_user
        @user = User.find_by uuid: params[:id]
      end
    end
  end
end
