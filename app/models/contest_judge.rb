# frozen_string_literal: true

class ContestJudge < ApplicationRecord
  belongs_to :contest
  has_many :contest_judge_routes, dependent: :destroy
  has_many :contest_routes, through: :contest_judge_routes

  before_validation :set_uuid

  validates :name, :code, presence: true

  def summary_to_json
    {
      id: id,
      name: name,
      code: code,
      uuid: uuid,
      contest_id: contest_id,
      contest_routes: contest_routes.map(&:summary_to_json),
    }
  end

  def detail_to_json
    routes_table = []
    contest_routes.includes(contest_route_group: [:contest_categories, { contest_stage_step: :contest_stage }]).find_each do |contest_route|
      data = contest_route.summary_to_json
      contest_route_group = contest_route.contest_route_group
      contest_stage_step = contest_route_group.contest_stage_step
      contest_stage = contest_stage_step.contest_stage
      data[:contest_stage] = {
        name: contest_stage.name,
        climbing_type: contest_stage.climbing_type,
        id: contest_stage.id
      }
      data[:contest_stage_step] = {
        name: contest_stage_step.name,
        id: contest_stage_step.id
      }
      data[:contest_route_group] = {
        name: contest_route_group.name,
        id: contest_route_group.id,
        genre_type: contest_route_group.genre_type
      }
      data[:contest_categories] = contest_route_group.contest_categories.map { |category| { name: category.name, id: category.id }}
      routes_table << data
    end
    summary_to_json.merge(
      {
        routes_table: routes_table,
        history: {
          created_at: created_at,
          updated_at: updated_at
        }
      }
    )
  end

  private

  def set_uuid
    self.uuid ||= SecureRandom.uuid
  end
end
