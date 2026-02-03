# frozen_string_literal: true

class ContestStageSerializer
  include JSONAPI::Serializer

  belongs_to :contest
  has_many :contest_stage_steps

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
