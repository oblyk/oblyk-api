# frozen_string_literal: true

class ContestParticipant < ApplicationRecord
  attr_accessor :skip_capacity_validation, :skip_subscription_mail

  belongs_to :contest_category
  belongs_to :contest_wave, optional: true
  belongs_to :user, optional: true
  has_one :gym, through: :contest_category
  has_one :contest, through: :contest_category

  has_many :contest_participant_ascents, dependent: :destroy
  has_many :contest_participant_steps, dependent: :destroy
  has_many :contest_stage_steps, through: :contest_participant_steps

  before_validation :normalize_values
  before_validation :set_token

  validates :first_name, :last_name, :genre, presence: true
  validates :genre, inclusion: { in: %w[male female] }
  validates :token, uniqueness: { scope: :contest }, on: :create
  validate :unique_participant
  validate :validate_age
  validate :validate_category_obligations
  validate :validate_capacity, unless: :skip_capacity_validation

  before_create :auto_distribute

  after_save :update_contest_category
  after_save :delete_caches
  after_save :update_contest
  after_save :update_category_count
  after_create :create_participant_step
  after_create :send_subscription_mail, unless: :skip_subscription_mail
  after_destroy :update_contest
  after_destroy :update_category_count
  after_destroy :delete_caches

  def age
    date_of_birth.present? ? ((Time.zone.now - Time.zone.parse(date_of_birth.to_s)) / 1.year.seconds).floor : nil
  end

  def summary_to_json
    Rails.cache.fetch("#{cache_key_with_version}/summary_contest_participant", expires_in: 28.days) do
      {
        token: token,
        id: id,
        first_name: first_name,
        last_name: last_name,
        affiliation: affiliation,
        genre: genre,
        contest_category_id: contest_category_id,
        contest_wave_id: contest_wave_id,
        user_id: user_id,
        contest_wave: {
          id: contest_wave&.id,
          name: contest_wave&.name
        },
        contest_category: {
          id: contest_category&.id,
          name: contest_category&.name
        },
      }
    end
  end

  def detail_to_json
    summary_to_json.merge(
      {
        user: user&.summary_to_json,
        contest_category: contest_category&.summary_to_json,
        contest_wave: contest_wave&.summary_to_json,
        date_of_birth: date_of_birth,
        email: email,
        history: {
          created_at: created_at,
          updated_at: updated_at
        }
      }
    )
  end

  def self.to_csv
    CSV.generate(headers: true, encoding: 'utf-8', col_sep: "\t") do |csv|
      csv << [
        'Nom',
        'Prénom',
        'Date de naissance',
        'Genre',
        'Email',
        'Affiliation',
        'Token',
        'Vague',
        'Catégorie'
      ]
      all.includes(:contest_wave, :contest_category).find_each do |participant|
        csv << [
          participant.last_name,
          participant.first_name,
          participant.date_of_birth,
          participant.genre,
          participant.email,
          participant.affiliation,
          participant.token,
          participant.contest_wave&.name,
          participant.contest_category.name
        ]
      end
    end
  end

  def steps
    steps = []
    contest_stage_steps.includes(:contest_route_groups).each do |step|
      start_time = nil
      end_time = nil
      start_date = nil
      end_date = nil
      additional_time = Contest::REGISTRATION_TOLERANCE
      routes = nil
      step.contest_route_groups.each do |route_group|
        wave = route_group.waveable ? route_group.contest_time_blocks.find_by(contest_wave_id: contest_wave_id) : nil
        next if route_group.waveable && wave.blank?

        if route_group.waveable
          time_block = route_group.contest_time_blocks.find_by contest_wave_id: contest_wave_id
          start_time = time_block.start_time
          end_time = time_block.end_time
          start_date = time_block.start_date || contest.start_date
          end_date = time_block.end_date
          additional_time = time_block.additional_time if time_block.additional_time
        else
          start_time = route_group.start_time
          end_time = route_group.end_time
          start_date = route_group.start_date || contest.start_date
          end_date = route_group.end_date
          additional_time = route_group.additional_time if route_group.additional_time
        end

        routes = []
        ascents = ContestParticipantAscent.where(
          contest_route_id: route_group.contest_routes.pluck(:id),
          contest_participant: self
        )
        route_group.contest_routes.each do |route|
          route_data = route.summary_to_json
          route_data[:ascent] = ascents.find { |ascent| ascent[:contest_route_id] == route.id }
          routes << route_data
        end
      end

      start_datetime = start_time.change({ year: start_date.year, day: start_date.day, month: start_date.month })
      end_datetime = end_time.change({ year: end_date.year, day: end_date.day, month: end_date.month })
      registration_end_at = end_datetime + additional_time.minutes

      steps << {
        id: step.id,
        name: step.name,
        self_reporting: step.self_reporting,
        climbing_type: step.contest_stage.climbing_type,
        step_order: step.step_order,
        ranking_type: step.ranking_type,
        start_time: start_time,
        end_time: end_time,
        start_date: start_date,
        end_date: end_date,
        start_datetime: start_datetime,
        end_datetime: end_datetime,
        registration_end_at: registration_end_at,
        routes: routes
      }
    end
    steps
  end

  def delete_summary_cache
    Rails.cache.delete("#{cache_key_with_version}/summary_contest_participant")
  end

  private

  def delete_caches
    contest.contest_categories.each(&:delete_summary_cache)
    contest.delete_summary_cache
  end

  def normalize_values
    self.first_name = first_name&.strip
    self.last_name = last_name&.strip
    self.email = email&.strip
    self.affiliation = affiliation&.strip

    self.email = nil if email.blank?
    self.affiliation = nil if affiliation.blank?
  end

  def set_token
    return if token.present?

    first_part = first_name.downcase.parameterize
    find = false
    loop = 0
    token_suggestion = nil
    letters = ('a'..'z').to_a
    until find
      loop += 1
      random_letters_number = 3
      random_letters_number = 4 if loop > 25
      random_letters_number = 5 if loop > 50
      random_letters_number = 6 if loop > 75
      random_letters = (0...random_letters_number).map { letters[rand(26)] }.join
      token_suggestion = "#{first_part}.#{random_letters}"
      find = !contest.contest_participants.where(token: token_suggestion).exists?
      raise if loop == 100
    end
    self.token = token_suggestion
  end

  def update_contest
    contest.update_from_participant!
  end

  def update_contest_category
    return unless saved_change_to_contest_category_id?

    contest_category.contest_participants_count = contest.contest_participants.where(contest_category_id: contest_category_id).count
    contest_category.save
  end

  def update_category_count
    contest_category.contest_participants_count = contest.contest_participants.where(contest_category_id: contest_category_id).count
    contest_category.save
  end

  def auto_distribute
    return unless contest_category.auto_distribute && contest_category.waveable && contest.contest_waves.count.positive?

    waves = contest.contest_waves.map do |wave|
      {
        id: wave.id,
        participant_count: wave.contest_participants.count
      }
    end
    waves.sort_by! { |wave| wave[:participant_count] }
    self.contest_wave_id = waves.first[:id]
  end

  def create_participant_step
    contest.contest_stages.each do |contest_stage|
      contest_stage.contest_stage_steps.order(:step_order).limit(1).each do |contest_stage_step|
        contest_stage_step.contest_route_groups.each do |contest_route_group|
          ContestParticipantStep.create(contest_participant_id: id, contest_stage_step_id: contest_stage_step.id) if contest_route_group.contest_route_group_categories.pluck(:contest_category_id).include? contest_category_id
        end
      end
    end
  end

  def validate_age
    errors.add(:base, "Le participant doit avoir 3 ans ou plus pour s'inscrire") if age < 3
    errors.add(:base, "Le participant semble trop vieux pour s'inscrire ...") if age >= 100
  end

  def validate_category_obligations
    return unless contest_category_id_changed?

    between_age = contest_category.registration_obligation == ContestCategory::BETWEEN_AGE
    uxx_age = ContestCategory::UXX_LIST.include? contest_category.registration_obligation
    min_age = contest_category.min_age
    max_age = contest_category.max_age

    # Validate category when 'between_age'
    if between_age
      errors.add(:base, "Le participant doit avoir plus de #{min_age} ans pour s'inscrire") if min_age.present? && max_age.blank? && age < min_age
      errors.add(:base, "Le participant doit avoir moins de #{max_age} ans pour s'inscrire") if min_age.blank? && max_age.present? && age > max_age
      errors.add(:base, "Le participant doit avoir entre #{min_age} et #{max_age} ans pour s'inscrire") if min_age.present? && max_age.present? && (age > max_age || age < min_age)
    end

    # Validate Uxx category
    return unless uxx_age

    participant_under_age = contest.start_date.year - date_of_birth.year
    categories = contest.contest_categories.map { |category| { id: category.id, under_age: category.under_age, previous_under_age: 0 } }
    categories.sort_by! { |category| category[:under_age] }
    categories.each_with_index do |_category, category_index|
      next if category_index.zero?

      categories[category_index][:previous_under_age] = categories[category_index - 1][:under_age]
    end
    categories.each do |category|
      next unless category[:id] == contest_category_id

      registrable = participant_under_age >= category[:previous_under_age] && participant_under_age < category[:under_age]
      unless registrable
        errors.add(:base, "Le participant en pas s'inscrire en #{contest_category.name}")
        break
      end
    end
  end

  def validate_capacity
    errors.add(:base, 'contest_is_complete') if new_record? && contest.total_capacity.present? && (contest.contest_participants_count || 0) >= contest.total_capacity
    errors.add(:base, 'category_is_complete') if contest_category_id_changed? && contest_category.capacity.present? && (contest_category.contest_participants_count || 0) >= contest_category.capacity
  end

  def unique_participant
    errors.add(:base, 'participant_is_already_registered') if contest.contest_participants.where.not(id: id).exists?(first_name: first_name, last_name: last_name, date_of_birth: date_of_birth)
  end

  def send_subscription_mail
    ContestParticipantMailer.with(contest_participant: self).subscribe.deliver_now
  end
end
