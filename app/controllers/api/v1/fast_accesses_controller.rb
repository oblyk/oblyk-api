# frozen_string_literal: true

module Api
  module V1
    class FastAccessesController < ApiController
      before_action :protected_by_session

      def index
        crag = Follow.includes(followable: { photo: { picture_attachment: :blob }, static_map_attachment: :blob })
                     .order(updated_at: :desc)
                     .find_by(followable_type: 'Crag', user: @current_user)
        crag = crag&.followable
        gym = Follow.includes(followable: { logo_attachment: :blob })
                    .order(updated_at: :desc)
                    .find_by(followable_type: 'Gym', user: @current_user)
        gym = gym&.followable

        follows_count = Follow.where(user: @current_user)
                              .group(:followable_type)
                              .count
        data = { follows_count: follows_count }

        if crag.present?
          avatar = if crag.photo_id.present?
                     crag.attachment_object(crag.photo&.picture, 'Crag_cover')
                   else
                     crag.attachment_object(crag.static_map)
                   end
          data[:crag] = {
            name: crag.name,
            city: crag.city,
            app_path: crag.app_path,
            attachments: {
              avatar: avatar
            }
          }
        end

        if gym.present?
          data[:gym] = {
            name: gym.name,
            city: gym.city,
            app_path: "#{gym.app_path}#{gym.optimal_spaces_path}",
            attachments: {
              avatar: gym.attachment_object(gym.logo)
            }
          }
        end

        data[:contests] = []
        contest_participations = @current_user.contest_participants
                                              .joins(contest_category: :contest)
                                              .where('contests.end_date >= ?', Date.current)
                                              .where('contests.subscription_start_date <= ?', Date.current)
        contest_participations.each do |contest_participation|
          contest = contest_participation.contest_category.contest.summary_to_json
          contest[:participant_token] = contest_participation.token
          data[:contests] << contest
        end

        render json: data, status: :ok
      end
    end
  end
end
