# frozen_string_literal: true

module Api
  module V1
    class PartnersController < ApiController
      def figures
        climbers = User.where(partner_search: true)
                       .where('EXISTS(SELECT * FROM locality_users WHERE deactivated_at IS NULL AND user_id = users.id)')
                       .where('users.last_activity_at > ?', Date.current - 3.years)
        render json: {
          count_global: climbers.count,
          count_last_week: climbers.where('partner_search_activated_at > ?', DateTime.current - 1.week).count
        }, status: :ok
      end

      def partners_around
        locality_user = LocalityUser.joins(:user, :locality)
                                    .where(users: { partner_search: true })
                                    .where('EXISTS(SELECT * FROM locality_users WHERE deactivated_at IS NULL AND user_id = users.id)')
                                    .where('users.last_activity_at > ?', Date.current - 3.years)
                                    .where(
                                      'getRange(localities.latitude, localities.longitude, :lat, :lng) < (locality_users.radius * 1000)',
                                      lat: params[:latitude].to_f,
                                      lng: params[:longitude].to_f
                                    )
        users = User.includes(avatar_attachment: :blob)
                    .where(id: locality_user.pluck(:user_id))
        render json: users.map(&:summary_to_json), status: :ok
      end
    end
  end
end
