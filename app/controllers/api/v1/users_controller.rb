# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApiController
      def index
        @users = User.all
      end
    end
  end
end
