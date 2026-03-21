# frozen_string_literal: true

module AttachmentsSerializerHelper
  extend ActiveSupport::Concern

  included do
    attribute :attachments do |object, params|
      data = {}
      type = object.class.name.to_sym
      params.fetch(:include_attachments, {})[type]&.each do |attachment_param|
        data[attachment_param] = send("#{attachment_param}_attachment", object)
      end
      data
    end
  end
end
