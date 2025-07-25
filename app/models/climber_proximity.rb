# frozen_string_literal: true

class ClimberProximity
  include AttachmentResizable

  attr_accessor :user

  def initialize(user)
    self.user = user
  end

  def results(page: 1, per_page: 25)
    sql_query = <<-SQL
      WITH t_ascent_crags AS (
          SELECT ascents.user_id,
                 COUNT(DISTINCT ascents.released_at) AS count
          FROM ascents INNER JOIN crag_routes ON ascents.crag_route_id = crag_routes.id AND ascents.user_id != :user_id,
               ascents my_ascents INNER JOIN crag_routes my_crag_routes ON my_ascents.crag_route_id = my_crag_routes.id AND my_ascents.user_id = :user_id
          WHERE ascents.released_at = my_ascents.released_at
            AND ascents.user_id != :user_id
            AND crag_routes.crag_id = my_crag_routes.crag_id
            AND ascents.released_at > CURRENT_DATE - INTERVAL 1 YEAR
            AND NOT EXISTS (SELECT * FROM follows WHERE follows.followable_type = 'User' AND follows.followable_id = ascents.user_id AND follows.user_id = :user_id)
          GROUP BY ascents.user_id
      ), t_ascent_gyms AS (
          SELECT ascents.user_id,
                 COUNT(DISTINCT ascents.released_at) AS count
          FROM ascents,
               ascents my_ascents
          WHERE ascents.released_at = my_ascents.released_at
            AND ascents.user_id != :user_id
            AND my_ascents.user_id = :user_id
            AND ascents.gym_id = my_ascents.gym_id
            AND ascents.released_at > CURRENT_DATE - INTERVAL 2 MONTH
            AND NOT EXISTS (SELECT * FROM follows WHERE follows.followable_type = 'User' AND follows.followable_id = ascents.user_id AND follows.user_id = :user_id)
          GROUP BY ascents.user_id
      ), t_common_friends AS (
          SELECT follows.user_id, COUNT(*) AS count
          FROM follows, follows my_follows
          WHERE follows.followable_type = 'User'
            AND my_follows.followable_type = 'User'
            AND follows.followable_id = my_follows.followable_id
            AND follows.followable_id != :oblyk_user_id
            AND my_follows.followable_id != :oblyk_user_id
            AND follows.accepted_at IS NOT NULL
            AND my_follows.accepted_at IS NOT NULL
            AND follows.user_id NOT IN (:user_id, :oblyk_user_id)
            AND my_follows.user_id = :user_id
          GROUP BY follows.user_id
      ), t_followed_crags AS (
          SELECT follows.user_id, COUNT(*) AS count
          FROM follows, follows my_follows
          WHERE follows.followable_type = 'Crag'
            AND my_follows.followable_type = 'Crag'
            AND follows.followable_id = my_follows.followable_id
            AND follows.accepted_at IS NOT NULL
            AND my_follows.accepted_at IS NOT NULL
            AND follows.user_id != :user_id
            AND my_follows.user_id = :user_id
            AND NOT EXISTS (SELECT * FROM follows my_friends WHERE my_friends.followable_type = 'User' AND my_friends.followable_id = follows.user_id AND my_friends.user_id = :user_id)
          GROUP BY follows.user_id
      ), t_followed_gyms AS (
          SELECT follows.user_id, COUNT(*) AS count
          FROM follows, follows my_follows
          WHERE follows.followable_type = 'Gym'
            AND my_follows.followable_type = 'Gym'
            AND follows.followable_id = my_follows.followable_id
            AND follows.accepted_at IS NOT NULL
            AND my_follows.accepted_at IS NOT NULL
            AND follows.user_id != :user_id
            AND my_follows.user_id = :user_id
            AND NOT EXISTS (SELECT * FROM follows my_friends WHERE my_friends.followable_type = 'User' AND my_friends.followable_id = follows.user_id AND my_friends.user_id = :user_id)
          GROUP BY follows.user_id
      )
      SELECT id,
             uuid,
             first_name,
             last_name,
             slug_name,
             t_ascent_crags.count AS ascent_crags,
             t_ascent_gyms.count AS ascent_gyms,
             t_common_friends.count AS common_friends,
             t_followed_crags.count AS followed_crags,
             t_followed_gyms.count AS followed_gyms,
             (
                 COALESCE(t_ascent_crags.count, 0) +
                 COALESCE(t_ascent_gyms.count, 0) +
                 COALESCE(t_common_friends.count, 0) * 2 +
                 COALESCE(t_followed_crags.count, 0) / 10 +
                 COALESCE(t_followed_gyms.count, 0) / 10
             ) AS proximity_points
      FROM users
               LEFT JOIN t_ascent_crags ON t_ascent_crags.user_id = users.id
               LEFT JOIN t_ascent_gyms ON t_ascent_gyms.user_id = users.id
               LEFT JOIN t_common_friends ON t_common_friends.user_id = users.id
               LEFT JOIN t_followed_crags ON t_followed_crags.user_id = users.id
               LEFT JOIN t_followed_gyms ON t_followed_gyms.user_id = users.id
      WHERE users.id != :user_id
        AND NOT EXISTS (SELECT * FROM follows my_friends WHERE my_friends.followable_type = 'User' AND my_friends.followable_id = users.id AND my_friends.user_id = :user_id)
      ORDER BY proximity_points DESC,
               users.last_activity_at DESC,
               users.id DESC
      LIMIT :limit OFFSET :offset
    SQL

    results = User.connection
                  .exec_query(
                    ApplicationRecord.sanitize_sql(
                      [
                        sql_query,
                        {
                          user_id: user.id,
                          oblyk_user_id: 57,
                          limit: per_page.to_i,
                          offset: (page.to_i - 1) * per_page.to_i
                        }
                      ]
                    )
                  )
    users = User.includes(avatar_attachment: :blob, banner_attachment: :blob)
                .where(id: results.map { |results| results['id'] })
                .group_by(&:id)

    rich_results = []
    results.each do |result|
      rich_results << build_user(
        result,
        users[result['id']].first
      )
    end
    rich_results
  end

  private

  def build_user(data, user)
    {
      id: user.id,
      uuid: user.uuid,
      slug_name: user.slug_name,
      first_name: user.first_name,
      full_name: user.full_name,
      attachments: {
        avatar: attachment_object(user.avatar),
        banner: attachment_object(user.banner)
      },
      proximity: {
        ascent_crags: data['ascent_crags'],
        ascent_gyms: data['ascent_gyms'],
        common_friends: data['common_friends'],
        followed_crags: data['followed_crags'],
        followed_gyms: data['followed_gyms'],
        proximity_points: data['proximity_points']
      }
    }
  end
end
