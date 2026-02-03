# frozen_string_literal: true

class AreaSerializer
  include JSONAPI::Serializer
  include AttachmentsSerializerHelper

  has_many :crags
  belongs_to :user

  attributes :id,
             :uuid,
             :slug_name,
             :first_name,
             :full_name,
             :app_path,
             :photos_count,
             :crags_count,
             :links_count,
             :versions_count,
             :articles_count,
             :place_of_sales_count,
             :next_guide_book_paper

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
