# frozen_string_literal: true

module Api
  module V1
    class GymAdministrationsController < ApiController
      before_action :protected_by_session
      before_action :protected_by_super_admin
      before_action :set_administration_request, only: %i[accept_request delete_request]

      def assigned
        gyms = []
        spaces_count = GymSpace.unscoped
                               .select('COUNT(*) AS count, gym_spaces.gym_id')
                               .where(deleted_at: nil)
                               .group(:gym_id)
                               .group_by(&:gym_id)

        routes_count = GymRoute.unscoped
                               .joins(gym_sector: :gym_space)
                               .select('COUNT(*) AS count, gym_spaces.gym_id')
                               .where(dismounted_at: nil, gym_spaces: { deleted_at: nil })
                               .group('gym_spaces.gym_id')
                               .group_by(&:gym_id)

        max_opened = GymRoute.unscoped
                             .joins(gym_sector: :gym_space)
                             .select('MAX(opened_at) AS max, gym_spaces.gym_id')
                             .where(dismounted_at: nil, gym_spaces: { deleted_at: nil })
                             .group('gym_spaces.gym_id')
                             .group_by(&:gym_id)

        Gym.includes(:gym_spaces, :gym_options, banner_attachment: :blob, logo_attachment: :blob)
           .where
           .not(assigned_at: nil)
           .order(:name)
           .find_each do |gym|
          summary_gym = gym.summary_to_json
          summary_gym[:route_count] = routes_count[gym.id]&.first.try(:[], :count) || 0
          summary_gym[:space_count] = spaces_count[gym.id]&.first.try(:[], :count) || 0
          summary_gym[:last_gym_route_mounted] = max_opened[gym.id]&.first.try(:[], :max)
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
