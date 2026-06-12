# frozen_string_literal: true

class AreaSerializer < BaseSerializer
  include AttachmentsSerializerHelper

  has_many :crags, lazy_load_data: true
  belongs_to :user

  attributes :id,
             :name,
             :slug_name,
             :app_path,
             :comments_count

  attribute :history do |object|
    {
      created_at: object.created_at,
      updated_at: object.updated_at
    }
  end

  def self.avatar_attachment(object)
    object.attachment_object(object.photo&.picture, 'Area_picture')
  end
end
