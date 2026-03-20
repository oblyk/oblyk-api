# frozen_string_literal: true

class PublicationAttachmentSerializer < BaseSerializer
  belongs_to :publication
  has_one :attachable, polymorphic: true

  attributes :id,
             :attachable_type,
             :attachable_id
end
