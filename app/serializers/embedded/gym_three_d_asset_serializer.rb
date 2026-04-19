# frozen_string_literal: true

module Embedded
  class GymThreeDAssetSerializer < BaseSerializer
    include AttachmentsSerializerHelper

    attributes :id,
               :name,
               :slug_name,
               :description,
               :three_d_gltf_url,
               :three_d_parameters
  end
end
