# frozen_string_literal: true

module Embedded
  class GymThreeDElementSerializer < BaseSerializer
    include AttachmentsSerializerHelper

    belongs_to :gym_three_d_asset, serializer: Embedded::GymThreeDAssetSerializer

    attributes :id,
               :gym_space_id,
               :three_d_position,
               :three_d_rotation,
               :three_d_scale
  end
end
