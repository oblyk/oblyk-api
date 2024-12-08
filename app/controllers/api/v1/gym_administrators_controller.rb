# frozen_string_literal: true

module Api
  module V1
    class GymAdministratorsController < ApiController
      include Gymable

      before_action :set_gym_administrator, only: %i[update show destroy]
      before_action -> { can? GymRole::MANAGE_TEAM_MEMBER }, except: %i[index show new_in_feeds update_feed_last_read]
      after_action :broadcast_new_roles, only: %i[create update]

      def index
        gym_administrators = @gym.gym_administrators
        render json: gym_administrators.map(&:summary_to_json), status: :ok
      end

      def show
        render json: @gym_administrator.detail_to_json, status: :ok
      end

      def create
        user = User.find_by email: gym_administrator_params[:requested_email]
        @gym_administrator = GymAdministrator.new gym_administrator_params
        @gym_administrator.user = user
        @gym_administrator.gym = @gym
        if @gym_administrator.save
          @gym_administrator.send_invitation_email! @current_user
          render json: @gym_administrator.detail_to_json, status: :ok
        else
          render json: { error: @gym_administrator.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @gym_administrator.update gym_administrator_params
          render json: @gym_administrator.detail_to_json, status: :ok
        else
          render json: { error: @gym_administrator.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @gym_administrator.destroy
          render json: {}, status: :ok
        else
          render json: { error: @gym_administrator.errors }, status: :unprocessable_entity
        end
      end

      def update_feed_last_read
        administrator = GymAdministrator.find_by user: @current_user, gym: @gym
        return unless administrator

        administrator.last_comment_feed_read_at = DateTime.now if params[:feed_type] == 'comment'
        administrator.last_video_feed_read_at = DateTime.now if params[:feed_type] == 'video'
        administrator.save
        head :no_content
      end

      def new_in_feeds
        administrator = GymAdministrator.find_by user: @current_user, gym: @gym
        return unless administrator

        feeds = params.fetch(:feeds, [])
        count_by_feeds = {}

        feeds.each do |feed|
          if feed == 'comment'
            route_comments_count =  Comment.joins('INNER JOIN gym_routes ON commentable_id = gym_routes.id')
                                           .joins('INNER JOIN gym_sectors ON gym_routes.gym_sector_id = gym_sectors.id')
                                           .joins('INNER JOIN gym_spaces ON gym_sectors.gym_space_id = gym_spaces.id')
                                           .where(
                                             gym_routes: { dismounted_at: nil },
                                             commentable_type: 'GymRoute',
                                             gym_spaces: { gym_id: @gym.id }
                                           )
                                           .where('comments.created_at >= ?', administrator.last_comment_feed_read_at)
                                           .count
            ascent_comments_count = Comment.joins('INNER JOIN ascents ON commentable_id = ascents.id')
                                           .joins('INNER JOIN gym_routes ON gym_route_id = gym_routes.id')
                                           .where(
                                             commentable_type: 'Ascent',
                                             gym_routes: { dismounted_at: nil },
                                             ascents: { gym_id: @gym.id }
                                           )
                                           .where('comments.created_at >= ?', administrator.last_comment_feed_read_at)
                                           .count
            count_by_feeds[feed] = {
              type: feed,
              last_read: administrator.last_comment_feed_read_at,
              count: route_comments_count + ascent_comments_count
            }
          end

          if feed == 'video'
            count = Video.where(viewable_type: 'GymRoute', viewable_id: @gym.gym_routes.mounted.pluck(:id))
                         .where('videos.created_at >= ?', administrator.last_video_feed_read_at)
                         .count
            count_by_feeds[feed] = {
              type: feed,
              last_read: administrator.last_video_feed_read_at,
              count: count
            }
          end

          next unless feed == 'follower'

          count = Follow.where(followable_type: 'Gym', followable_id: @gym.id)
                        .where('follows.created_at >= ?', administrator.last_follower_feed_read_at)
                        .count
          count_by_feeds[feed] = {
            type: feed,
            last_read: administrator.last_follower_feed_read_at,
            count: count
          }
        end

        render json: count_by_feeds, status: :ok
      end

      private

      def set_gym_administrator
        @gym_administrator = GymAdministrator.find params[:id]
      end

      def gym_administrator_params
        params.require(:gym_administrator).permit(
          :id,
          :requested_email,
          :subscribe_to_comment_feed,
          :subscribe_to_video_feed,
          roles: []
        )
      end

      def broadcast_new_roles
        return unless @gym_administrator.user

        ActionCable.server.broadcast "fetch_user_#{@gym_administrator.user.id}", true
      end
    end
  end
end
