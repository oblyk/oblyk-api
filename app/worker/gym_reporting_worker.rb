# frozen_string_literal: true

class GymReportingWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default

  def perform
    start_of_week = Date.current.prev_week.beginning_of_week
    end_of_week = Date.current.prev_week.end_of_week

    assigned_gyms = Gym.where.not(assigned_at: nil).pluck(:id)

    follower_by_gyms = Follow.select('COUNT(*) AS count, followable_id')
                             .where('follows.created_at <= ?', end_of_week.end_of_day)
                             .where(followable_type: 'Gym')
                             .where(followable_id: assigned_gyms)
                             .group('followable_id')
                             .group_by(&:followable_id)

    new_followers_in_week = Follow.select('COUNT(*) AS count, followable_id')
                                  .where(created_at: start_of_week.beginning_of_day..end_of_week.end_of_day)
                                  .where(followable_type: 'Gym')
                                  .where(followable_id: assigned_gyms)
                                  .group('followable_id')
                                  .group_by(&:followable_id)

    gym_routes_by_gyms = GymRoute.select('COUNT(*) AS count, gym_routes.climbing_type AS climbing_type, gym_spaces.gym_id AS gym_id')
                                 .joins(gym_sector: :gym_space)
                                 .where('opened_at <= :date AND (dismounted_at IS NULL OR dismounted_at > :date)', date: end_of_week.end_of_day)
                                 .where(gym_spaces: { gym_id: assigned_gyms })
                                 .group('climbing_type, gym_id')
                                 .group_by(&:gym_id)

    new_gym_routes_in_week = GymRoute.select('COUNT(*) AS count, gym_routes.climbing_type AS climbing_type, gym_spaces.gym_id AS gym_id')
                                     .joins(gym_sector: :gym_space)
                                     .where(opened_at: start_of_week.beginning_of_day..end_of_week.end_of_day)
                                     .where(gym_spaces: { gym_id: assigned_gyms })
                                     .group('climbing_type, gym_id')
                                     .group_by(&:gym_id)

    dismounted_routes_in_week = GymRoute.select('COUNT(*) AS count, gym_routes.climbing_type AS climbing_type, gym_spaces.gym_id AS gym_id')
                                        .joins(gym_sector: :gym_space)
                                        .where(dismounted_at: start_of_week.beginning_of_day..end_of_week.end_of_day)
                                        .where(gym_spaces: { gym_id: assigned_gyms })
                                        .group('climbing_type, gym_id')
                                        .group_by(&:gym_id)

    ascents_in_week = AscentGymRoute.select('COUNT(*) AS count, gym_id AS gym_id')
                                    .where(gym_id: assigned_gyms)
                                    .where(released_at: start_of_week.beginning_of_day..end_of_week.end_of_day)
                                    .group('gym_id')
                                    .group_by(&:gym_id)

    likes_in_week = Like.select('COUNT(*) AS count, gym_spaces.gym_id AS gym_id')
                        .joins('INNER JOIN gym_routes ON gym_routes.id = likes.likeable_id AND likes.likeable_type = "GymRoute"')
                        .joins('INNER JOIN gym_sectors ON gym_sectors.id = gym_routes.gym_sector_id')
                        .joins('INNER JOIN gym_spaces ON gym_spaces.id = gym_sectors.gym_space_id')
                        .where(gym_spaces: { gym_id: assigned_gyms })
                        .where(created_at: start_of_week.beginning_of_day..end_of_week.end_of_day)
                        .group('gym_id')
                        .group_by(&:gym_id)

    videos_in_week = Video.select('COUNT(*) AS count, gym_spaces.gym_id AS gym_id')
                          .joins('INNER JOIN gym_routes ON gym_routes.id = videos.viewable_id AND videos.viewable_type = "GymRoute"')
                          .joins('INNER JOIN gym_sectors ON gym_sectors.id = gym_routes.gym_sector_id')
                          .joins('INNER JOIN gym_spaces ON gym_spaces.id = gym_sectors.gym_space_id')
                          .where(gym_spaces: { gym_id: assigned_gyms })
                          .where(created_at: start_of_week.beginning_of_day..end_of_week.end_of_day)
                          .group('gym_id')
                          .group_by(&:gym_id)

    comments_in_week = Comment.select('COUNT(*) AS count, gym_spaces.gym_id AS gym_id')
                              .joins('INNER JOIN gym_routes ON gym_routes.id = comments.commentable_id AND comments.commentable_type = "GymRoute"')
                              .joins('INNER JOIN gym_sectors ON gym_sectors.id = gym_routes.gym_sector_id')
                              .joins('INNER JOIN gym_spaces ON gym_spaces.id = gym_sectors.gym_space_id')
                              .where(gym_spaces: { gym_id: assigned_gyms })
                              .where(created_at: start_of_week.beginning_of_day..end_of_week.end_of_day)
                              .group('gym_id')
                              .group_by(&:gym_id)

    users = User.includes(gym_administrators: :gym)
                .where(gym_administrators: { gym_id: assigned_gyms })
                .where(gym_administrators: { weekly_report: true })

    users.each do |user|
      figures = []
      user.gym_administrators.each do |administrator|
        gym = administrator.gym
        logo = nil
        logo = gym.logo_attachment_object[:variant_path].gsub(':variant', 'fit=crop,width=50,height=50') if gym.logo_attachment_object[:attached]
        figure = {
          gym: {
            name: gym.name,
            id: gym.id,
            slug_name: gym.slug_name,
            logo_path: logo
          },
          gym_routes: {},
          follower: {
            count: follower_by_gyms[gym.id]&.first.try(:[], :count) || 0,
            new: new_followers_in_week[gym.id]&.first.try(:[], :count) || 0
          },
          likes_count: likes_in_week[gym.id]&.first.try(:[], :count) || 0,
          comments_count: comments_in_week[gym.id]&.first.try(:[], :count) || 0,
          videos_count: videos_in_week[gym.id]&.first.try(:[], :count) || 0,
          ascents_count: ascents_in_week[gym.id]&.first.try(:[], :count) || 0
        }
        gym_routes_by_gyms[gym.id]&.group_by(&:climbing_type)&.each do |climbing_type, value|
          figure[:gym_routes][climbing_type] ||= { count: 0, new: 0, dismounted: 0 }
          figure[:gym_routes][climbing_type][:count] = value.first[:count]
        end
        new_gym_routes_in_week[gym.id]&.group_by(&:climbing_type)&.each do |climbing_type, value|
          figure[:gym_routes][climbing_type] ||= { count: 0, new: 0, dismounted: 0 }
          figure[:gym_routes][climbing_type][:new] = value.first[:count]
        end
        dismounted_routes_in_week[gym.id]&.group_by(&:climbing_type)&.each do |climbing_type, value|
          figure[:gym_routes][climbing_type] ||= { count: 0, new: 0, dismounted: 0 }
          figure[:gym_routes][climbing_type][:dismounted] = value.first[:count]
        end
        figures << figure
      end
      GymMailer.with(user: user, start_of_week: start_of_week, end_of_week: end_of_week, figures: figures)
               .weekly_report.deliver_now
    end

    next_monday = Time.zone.now.beginning_of_week + 1.week + 9.hours
    GymReportingWorker.perform_at(next_monday)
  end
end
