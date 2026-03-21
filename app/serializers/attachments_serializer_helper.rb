# frozen_string_literal: true

module AttachmentsSerializerHelper
  extend ActiveSupport::Concern

  attribute :attachments do |object, params|
    data = {}
    type = class_name.gsub('Serializer', '').to_sym
    params.fetch(:include_attachments, {})[type]&.each do |attachment_param|
      data[attachment_param] = send("#{attachment_param}_attachment", object)
    end
    data
  end
end
