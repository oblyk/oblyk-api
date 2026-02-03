# frozen_string_literal: true

class PhotoSerializer
  include JSONAPI::Serializer
  include AttachmentsSerializerHelper

  belongs_to :illustrable, polymorphic: true
  belongs_to :user

  attributes :id,
             :description,
             :exif_model,
             :exif_make,
             :source,
             :alt,
             :copyright_by,
             :copyright_nc,
             :copyright_nd,
             :photo_height,
             :photo_width,
             :likes_count,
             :illustrable_type,
             :illustrable_id,
             :copy,
             :app_path

  attribute :history do |object|
    {
      created_at: object.created_at,
      updated_at: object.updated_at
    }
  end

  def self.picture_attachment(object)
    object.attachment_object(object.picture)
  end
end
