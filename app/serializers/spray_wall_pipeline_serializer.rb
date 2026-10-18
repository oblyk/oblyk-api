# frozen_string_literal: true

class SprayWallPipelineSerializer < BaseSerializer
  belongs_to :spray_wall

  attributes :id,
             :service,
             :status,
             :start_at,
             :end_at

  attribute :running, &:run?
end
