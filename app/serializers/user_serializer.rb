# frozen_string_literal: true

class UserSerializer < BaseSerializer
  include AttachmentsSerializerHelper

  attributes :id,
             :uuid,
             :slug_name,
             :first_name,
             :full_name,
             :app_path

  attribute :name, &:full_name

  def self.avatar_attachment(object)
    object.attachment_object(object.avatar)
  end
end
