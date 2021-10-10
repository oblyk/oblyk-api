# frozen_string_literal: true

module AttachmentResizable
  extend ActiveSupport::Concern

  def resize_attachment(attachment, size)
    return unless attachment.attached?

    Rails.application.routes.url_helpers.rails_representation_url(attachment.variant(resize: size).processed, only_path: true)
  rescue StandardError
    nil
  end
end
