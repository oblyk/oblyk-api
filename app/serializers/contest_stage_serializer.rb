# frozen_string_literal: true

class ContestStageSerializer < BaseSerializer
  belongs_to :contest
  has_many :contest_stage_steps, lazy_load_data: true

  attributes :id,
             :climbing_type,
             :name,
             :description,
             :stage_order,
             :default_ranking_type,
             :contest_id,
             :stage_date

  attribute :history do |object|
    {
      created_at: object.created_at,
      updated_at: object.updated_at
    }
  end
end
