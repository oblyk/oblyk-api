# frozen_string_literal: true

class GuideBookPaperSerializer
  include JSONAPI::Serializer
  include AttachmentsSerializerHelper

  attributes :id,
             :name,
             :slug_name,
             :app_path,
             :author,
             :editor,
             :publication_year,
             :price_cents,
             :ean,
             :vc_reference,
             :number_of_page,
             :weight,
             :funding_status,
             :follows_count

  attribute :price do |object|
    object.price_cents ? object.price_cents.to_d / 100 : nil
  end

  def self.cover_attachment(object)
    object.attachment_object(object.cover)
  end

  def self.avatar_attachment(object)
    cover_attachment(object)
  end
end
