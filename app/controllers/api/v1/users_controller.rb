# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApiController
      before_action :protected_by_session, except: %i[index]
      before_action :set_user, only: %i[show update]

      def index
        @users = User.all
      end

      def show; end

      def update
        if @user.update(user_params)
          render 'api/v1/users/show'
        else
          render json: @user.errors, status: :internal_server_error
        end
      end

      private

      def set_user
        @user = @current_user
      end

      def user_params
        params.require(:user).permit(
          :first_name,
          :last_name,
          :date_of_birth,
          :genre,
          :description
        )
      end
    end
  end
end
