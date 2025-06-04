# frozen_string_literal: true

class Gym < ApplicationRecord
  include Geolocable
  include SoftDeletable
  include Searchable
  include Slugable
  include ParentFeedable
  include ActivityFeedable
  include AttachmentResizable
  include StripTagable
  include Emailable

  has_paper_trail only: %i[
    name
    description
    address
    postal_code
    code_country
    country
    city
    big_city
    region
    email
    phone_number
    web_site
    bouldering
    sport_climbing
    pan
    fun_climbing
    training_space
    latitude
    longitude
  ], if: proc { |_obj| ENV['PAPER_TRAIL'] == 'true' }

  RANKING_TYPES = %w[division fixed_points point_by_grade].freeze
  PLAN_LIST = %w[free free_trial full_package].freeze
  GYM_TYPE_LIST = %w[club private].freeze

  has_one_attached :logo
  has_one_attached :banner
  belongs_to :user, optional: true
  belongs_to :department, optional: true
  belongs_to :gym_billing_account, optional: true
  has_many :follows, as: :followable
  has_many :videos, as: :viewable
  has_many :comments, as: :commentable
  has_many :feeds, as: :feedable
  has_many :gym_administrators
  has_many :gym_administration_requests
  has_many :gym_grades # TODO : DELETE AFTER MIGRATION
  has_many :gym_spaces
  has_many :gym_space_groups
  has_many :reports, as: :reportable
  has_many :ascents
  has_many :gym_sectors, through: :gym_spaces
  has_many :gym_routes, through: :gym_sectors
  has_many :gym_openers
  has_many :gym_climbing_styles
  has_many :contests
  has_many :gym_options
  has_many :gym_label_templates
  has_many :gym_chain_gyms
  has_many :gym_chains, through: :gym_chain_gyms
  has_many :gym_three_d_elements
  has_many :gym_levels
  has_many :gym_opening_sheets
  has_many :indoor_subscription_gyms
  has_many :indoor_subscriptions, through: :indoor_subscription_gyms

  validates :logo, blob: { content_type: :image }, allow_nil: true
  validates :banner, blob: { content_type: :image }, allow_nil: true
  validates :name, :latitude, :longitude, :address, :country, :city, :big_city, presence: true
  validates :boulder_ranking, :sport_climbing_ranking, :pan_ranking, inclusion: { in: RANKING_TYPES }, allow_nil: true
  validates :plan, inclusion: { in: PLAN_LIST }, allow_nil: true
  validates :gym_type, inclusion: { in: GYM_TYPE_LIST }, allow_nil: true

  before_validation :normalize_ascents_multiplier
  after_save :historize_around_towns
  after_save :delete_routes_caches

  def all_championships
    Championship.where('gym_id = :gym_id OR id IN (SELECT championship_id FROM championship_contests INNER JOIN contests ON championship_contests.contest_id = contests.id WHERE gym_id = :gym_id)', gym_id: id)
  end

  def location
    [latitude, longitude]
  end

  def to_geo_json(minimalistic: false)
    Rails.cache.fetch("#{cache_key_with_version}/#{'minimalistic_' if minimalistic}geo_json_gym", expires_in: 28.days) do
      features = {
        type: 'Feature',
        properties: {
          type: 'Gym',
          id: id,
          name: name,
          icon: "gym-marker-#{climbing_key}"
        },
        geometry: { type: 'Point', "coordinates": [Float(longitude), Float(latitude), 0.0] }
      }
      unless minimalistic
        features[:properties].merge!(
          {
            name: name,
            slug_name: slug_name,
            climbing_key: climbing_key,
            localization: "#{city}, #{region}",
            bouldering: bouldering,
            sport_climbing: sport_climbing,
            pan: pan,
            fun_climbing: fun_climbing,
            training_space: training_space
          }
        )
      end
      features
    end
  end

  def administered?
    assigned_at.present?
  end

  def administered!
    self.boulder_ranking ||= 'division'
    self.sport_climbing_ranking ||= 'point_by_grade'
    self.pan_ranking ||= 'division'
    self.assigned_at ||= Time.current
    self.plan ||= 'free'
    init_gym_levels
    init_ascents_multiplier
    save
  end

  def admin_app_path
    "#{ENV['OBLYK_APP_URL']}/gyms/#{id}/#{slug_name}/admins"
  end

  def climbing_key
    key = ''
    key += bouldering || pan ? '1' : '0'
    key += sport_climbing ? '1' : '0'
    key += fun_climbing ? '1' : '0'
    key
  end

  def logo_attachment_object
    attachment_object(logo)
  end

  def gym_spaces_with_anchor?
    gym_spaces.where(anchor: true).count.positive?
  end

  def ranking?
    boulder_ranking.present? || sport_climbing_ranking.present? || pan_ranking.present?
  end

  def summary_to_json
    Rails.cache.fetch("#{cache_key_with_version}/summary_gym", expires_in: 28.days) do
      {
        id: id,
        name: name,
        slug_name: slug_name,
        description: description,
        email: email,
        phone_number: phone_number,
        web_site: web_site,
        latitude: latitude,
        longitude: longitude,
        code_country: code_country,
        country: country,
        city: city,
        big_city: big_city,
        region: region,
        address: address,
        postal_code: postal_code,
        sport_climbing: sport_climbing,
        bouldering: bouldering,
        pan: pan,
        fun_climbing: fun_climbing,
        training_space: training_space,
        boulder_ranking: boulder_ranking,
        pan_ranking: pan_ranking,
        sport_climbing_ranking: sport_climbing_ranking,
        administered: administered?,
        gym_options: gym_options.map(&:summary_to_json),
        gym_spaces_count: gym_spaces.size,
        three_d_camera_position: three_d_camera_position,
        representation_type: representation_type,
        gym_type: gym_type,
        gym_billing_account_id: gym_billing_account_id,
        attachments: {
          logo: attachment_object(logo),
          banner: attachment_object(banner)
        }
      }
    end
  end

  def detail_to_json
    summary_to_json.merge(
      {
        follow_count: follows.count,
        versions_count: versions.count,
        gym_chains: gym_chains.map(&:summary_to_json),
        gym_spaces: gym_spaces.unarchived.map(&:summary_to_json),
        gym_space_groups: gym_space_groups.map(&:summary_to_json),
        sorts_available: sorts_available,
        display_ranking: ranking?,
        ascents_multiplier: ascents_multiplier,
        plan: plan,
        gym_climbing_styles: gym_climbing_styles.activated.map { |style| { style: style.style, climbing_type: style.climbing_type, color: style.color } },
        gym_spaces_with_anchor: gym_spaces_with_anchor?,
        upcoming_contests: contests.upcoming.map(&:summary_to_json),
        gym_label_templates: gym_label_templates.unarchived.map { |label| { name: label.name, id: label.id } },
        have_indoor_subscriptions: indoor_subscriptions.count.positive?,
        subscription_possibility: subscription_possibility,
        levels: levels,
        history: {
          created_at: created_at,
          updated_at: updated_at
        }
      }
    )
  end

  def delete_summary_cache
    Rails.cache.delete("#{cache_key_with_version}/summary_gym")
  end

  def init_gym_levels
    gym_levels << GymLevel.new(climbing_type: Climb::BOULDERING, grade_system: nil, level_representation: GymLevel::TAG_AND_HOLD_REPRESENTATION) unless GymLevel.exists?(gym_id: id, climbing_type: Climb::BOULDERING)
    gym_levels << GymLevel.new(climbing_type: Climb::SPORT_CLIMBING, grade_system: 'french', level_representation: GymLevel::HOLD_REPRESENTATION) unless GymLevel.exists?(gym_id: id, climbing_type: Climb::SPORT_CLIMBING)
    gym_levels << GymLevel.new(climbing_type: Climb::PAN, grade_system: 'french', level_representation: GymLevel::TAG_REPRESENTATION) unless GymLevel.exists?(gym_id: id, climbing_type: Climb::PAN)
  end

  def init_ascents_multiplier
    ascents_multiplier = {}
    [Climb::BOULDERING, Climb::SPORT_CLIMBING, Climb::PAN].each do |type|
      ascents_multiplier[type] = {
        onsight: 1.1,
        flash: 1.05,
        red_point: 1
      }
      if type == Climb::SPORT_CLIMBING
        ascents_multiplier[type][:lead_climb] = 1
        ascents_multiplier[type][:top_rope] = 0.5
      end
    end
    self.ascents_multiplier ||= ascents_multiplier
  end

  def update_plan!
    plan = 'free'
    active_subscription = indoor_subscriptions.active.order(created_at: :desc).first
    plan = active_subscription.in_free_trial? ? 'free_trial' : 'full_package' if active_subscription.present?
    self.plan = plan
    save
  end

  def levels
    levels = {}
    gym_levels.order("FIELD(climbing_type, 'sport_climbing', 'bouldering', 'pan')").each do |gym_level|
      levels[gym_level.climbing_type] = gym_level.summary_to_json
    end
    levels
  end

  def subscription_possibility
    return 'start_a_free_trial' if indoor_subscriptions.count.zero?

    indoor_subscriptions.each do |subscription|
      return 'reactivate_my_subscription' if subscription.payment_status == 'waiting_first_payment' && subscription.end_date.present? && subscription.end_date <= Date.current
      return 'manage_my_subscription' if subscription.payment_status == 'paid' && (subscription.end_date.blank? || subscription.end_date <= Date.current)
    end
    'resubscribe'
  end

  private

  def sorts_available
    sorts_by = GymRoute.mounted
                       .select(
                         "SUM(coalesce(level_index, 0)) AS 'has_level',
                         SUM(COALESCE(min_grade_value, 0)) AS 'has_grade',
                         SUM(COALESCE(points, 0)) AS 'has_fixed_point',
                         GROUP_CONCAT(DISTINCT gym_routes.climbing_type) AS 'climbing_types',
                         SUM(COALESCE(ascents_count, 0)) AS 'has_ascents',
                         SUM(COALESCE(likes_count, 0)) AS 'has_likes',
                         SUM(COALESCE(comments_count, 0)) AS 'has_comments'"
                       )
                       .joins(gym_sector: :gym_space)
                       .where(gym_sectors: { gym_spaces: { gym_id: id } })
    calculated_point_system = false
    sorts_by = sorts_by&.first
    if sorts_by['has_fixed_point']&.zero?
      climbing_types = sorts_by['climbing_types'].split(',')
      climbing_types.each do |climbing_type|
        calculated_point_system = true if %w[division point_by_grade].include?(sport_climbing_ranking) && climbing_type == 'sport_climbing'
        calculated_point_system = true if %w[division point_by_grade].include?(pan_ranking) && climbing_type == 'pan'
        calculated_point_system = true if %w[division point_by_grade].include?(boulder_ranking) && climbing_type == 'boulder'
      end
    end

    {
      difficulty_by_level: sorts_by['has_level']&.positive?,
      difficulty_by_grade: sorts_by['has_grade']&.positive?,
      difficulty_by_point: sorts_by['has_fixed_point']&.positive? || calculated_point_system,
      ascents_count: sorts_by['has_ascents']&.positive?,
      likes_count: sorts_by['has_likes']&.positive?,
      comments_count: sorts_by['has_comments']&.positive?
    }
  end

  def search_indexes
    [
      { value: name, column_names: %i[name] },
      { value: city, column_names: %i[city] },
      { value: big_city, column_names: %i[big_city] }
    ]
  end

  def historize_around_towns
    logo_change = logo.attached? && logo.attachment.created_at > (Time.current - 5.minutes)

    if saved_change_to_name? ||
       saved_change_to_latitude? ||
       saved_change_to_longitude? ||
       saved_change_to_code_country? ||
       saved_change_to_city? ||
       logo_change
      HistorizeTownsAroundWorker.perform_in(1.hour, latitude, longitude, Time.current)
    end
  end

  def delete_routes_caches
    gym_routes.find_each(&:delete_summary_cache) if saved_change_to_boulder_ranking? || saved_change_to_sport_climbing_ranking? || saved_change_to_pan_ranking?
  end

  def normalize_ascents_multiplier
    return unless ascents_multiplier_changed?

    ascents_multiplier&.each do |k, _v|
      ascents_multiplier[k].each do |k2, v2|
        ascents_multiplier[k][k2] = v2.to_f
      end
    end
  end
end
