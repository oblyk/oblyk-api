# frozen_string_literal: true

class ContestRouteGroup < ApplicationRecord
  belongs_to :contest_stage_step
  has_one :contest_stage, through: :contest_stage_step
  has_one :contest, through: :contest_stage

  has_many :contest_route_group_categories, dependent: :destroy
  has_many :contest_categories, through: :contest_route_group_categories
  has_many :contest_routes, dependent: :destroy
  has_many :contest_time_blocks, dependent: :destroy
  has_many :contest_waves, through: :contest_time_blocks

  before_validation :normalize_attributes
  after_validation :validate_categories

  after_save :delete_caches
  after_destroy :delete_caches

  validates :genre_type, inclusion: { in: %w[unisex male female] }
  validates :contest_categories, length: { minimum: 1, message: 'you_must_choose_one' }

  accepts_nested_attributes_for :contest_time_blocks, reject_if: proc { |attrs| attrs.all? { |_k, v| v.blank? } }

  def summary_to_json
    {
      id: id,
      name: name,
      genre_type: genre_type,
      waveable: waveable,
      route_group_date: route_group_date,
      start_time: start_time,
      end_time: end_time,
      start_date: start_date,
      end_date: end_date,
      additional_time: additional_time,
      number_participants_for_next_step: number_participants_for_next_step,
      contest_stage_step_id: contest_stage_step_id,
      contest_stage_step: {
        id: contest_stage_step.id,
        name: contest_stage_step.name
      },
      contest_categories: contest_categories.map(&:summary_to_json),
      contest_category_ids: contest_categories.pluck(:id),
      contest_routes: contest_routes.map(&:summary_to_json),
      contest_time_blocks: contest_time_blocks.map(&:summary_to_json)
    }
  end

  def detail_to_json
    summary_to_json.merge(
      {
        history: {
          created_at: created_at,
          updated_at: updated_at
        }
      }
    )
  end

  def name
    "#{contest_stage_step.name} #{contest_categories.map(&:name).join(', ')} #{genre_type}"
  end

  private

  def delete_caches
    contest_stage_step.delete_summary_cache
  end

  def normalize_attributes
    if waveable
      self.start_time = nil
      self.end_time = nil
      self.start_date = nil
      self.end_date = nil
    end

    return unless contest.one_day_event? && !waveable

    self.start_date = contest.start_date
    self.end_date = contest.end_date
  end

  def validate_categories
    contest_categories.each do |category|
      contest_stage_step.contest_route_groups.where.not(id: id).each do |contest_route_group|
        route_group_category = ContestRouteGroupCategory.find_by contest_category_id: category.id, contest_route_group_id: contest_route_group.id

        next if route_group_category.blank? || route_group_category.contest_route_group.genre_type != genre_type

        errors.add(:base, 'category_is_taken_in_this_step')
      end
    end
  end
end
