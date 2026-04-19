# frozen_string_literal: true

module Embedded
  class GymSectorSerializer < BaseSerializer
    include AttachmentsSerializerHelper

    belongs_to :gym_space, serializer: Embedded::GymSpaceSerializer

    attributes :id,
               :name,
               :three_d_path,
               :three_d_height,
               :three_d_label_options,
               :three_d_elevated,
               :polygon,
               :gym_space_id
  end
end
