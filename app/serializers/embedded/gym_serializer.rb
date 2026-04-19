# frozen_string_literal: true

module Embedded
  class GymSerializer < BaseSerializer
    include AttachmentsSerializerHelper

    has_many :gym_spaces, serializer: Embedded::GymSpaceSerializer
    has_many :gym_three_d_elements, serializer: Embedded::GymThreeDElementSerializer

    attributes :name,
               :id,
               :app_path,
               :representation_type

    def self.logo_attachment(object)
      object.attachment_object(object.logo)
    end
  end
end
