# frozen_string_literal: true

module Api
  module Embedded
    class GymsController < EmbeddedController
      before_action :set_gym

      def show
        gym = Gym.includes(gym_spaces: [:gym_sectors, { plan_attachment: :blob, three_d_picture_attachment: :blob }])
                 .where(gym_spaces: { draft: false, archived_at: nil })
                 .references(:gym_spaces)
                 .find(@gym.id)

        serializer = ::Embedded::GymSerializer.new(
          gym,
          {
            include: [
              :gym_spaces,
              'gym_spaces.gym_sectors',
              :gym_three_d_elements,
              'gym_three_d_elements.gym_three_d_asset'
            ],
            params: {
              include_attachments: {
                Gym: %i[logo],
                GymSpace: %i[avatar plan three_d_picture]
              }
            }
          }
        )

        render json: serializer.serializable_hash, status: :ok
      end

      private

      def set_gym
        @gym = Gym.where.not(assigned_at: nil).find params[:id]

        render json: { error: 'Gym not found' }, status: :not_found unless @gym
      end
    end
  end
end
