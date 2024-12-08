# frozen_string_literal: true

module Api
  module V1
    class GymAdministrationsController < ApiController
      before_action :protected_by_session
      before_action :protected_by_super_admin
      before_action :set_administration_request, only: %i[accept_request delete_request]

      def assigned
        gyms = []
        Gym.where.not(assigned_at: nil).order(:name).find_each do |gym|
          summary_gym = gym.summary_to_json
          summary_gym[:route_count] = gym.gym_routes.mounted.count
          summary_gym[:space_count] = gym.gym_spaces.count
          summary_gym[:last_gym_route_mounted] = gym.gym_routes.maximum(:opened_at)
          gyms << summary_gym
        end
        render json: gyms, status: :ok
      end

      def requested
        requests = GymAdministrationRequest.joins(:gym)
                                           .where(gyms: { assigned_at: nil })
                                           .order(created_at: :desc)
        render json: requests.map(&:summary_to_json), status: :ok
      end

      def accept_request
        @administration_request.accept!
        GymMailer.with(user: @administration_request.user, gym: @administration_request.gym, email: @administration_request.email)
                 .accept_administrator
                 .deliver_later
        head :no_content
      end

      def delete_request
        @administration_request.destroy
        head :no_content
      end

      def add_option
        option_type = params[:option_type]
        option = GymOption.find_or_initialize_by gym_id: params[:gym_id], option_type: option_type
        option.start_date = Date.current
        option.unlimited_unit = true if option_type == GymOption::OPTION_CONTEST
        option.save
        head :no_content
      end

      def delete_option
        option = GymOption.find_by gym_id: params[:gym_id], option_type: params[:option_type]
        option&.destroy
        head :no_content
      end

      private

      def set_administration_request
        @administration_request = GymAdministrationRequest.find params[:id]
      end

      def protected_by_super_admin
        protected_by_session
        forbidden unless @current_user.super_admin
      end
    end
  end
end
