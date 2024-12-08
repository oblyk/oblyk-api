# frozen_string_literal: true

module AttachmentResizable
  extend ActiveSupport::Concern

  def resize_attachment(attachment, size)
    return unless attachment.attached?

    # Resize attachement
    resize_attachement = attachment.variant(resize: size).processed

    if Rails.application.config.cdn_storage_services.include? Rails.application.config.active_storage.service
      # Use CLOUDFLARE R2 CDN
      "#{ENV['CLOUDFLARE_R2_DOMAIN']}/#{resize_attachement.key}"

    else
      # Use local active storage
      "#{ENV['OBLYK_API_URL']}#{Rails.application.routes.url_helpers.rails_representation_url(resize_attachement, only_path: true)}"
    end
  rescue StandardError
    nil
  end

  def resize_to_limit_attachment(attachment, size)
    return unless attachment.attached?

    # Resize attachement
    resize_attachement = attachment.variant(resize_to_limit: size).processed

    if Rails.application.config.cdn_storage_services.include? Rails.application.config.active_storage.service
      # Use CLOUDFLARE R2 CDN
      "#{ENV['CLOUDFLARE_R2_DOMAIN']}/#{resize_attachement.key}"

    else
      # Use local active storage
      "#{ENV['OBLYK_API_URL']}#{Rails.application.routes.url_helpers.rails_representation_url(resize_attachement, only_path: true)}"
    end
  rescue StandardError
    nil
  end

  def crop_attachment(attachment, size)
    return unless attachment.attached?

    # Resize attachement
    resize_attachement = attachment.variant({ combine_options: { gravity: 'Center', resize: "#{size}^", crop: "#{size}+0+0" } }).processed

    if Rails.application.config.cdn_storage_services.include? Rails.application.config.active_storage.service
      # Use CLOUDFLARE R2 CDN
      "#{ENV['CLOUDFLARE_R2_DOMAIN']}/#{resize_attachement.key}"

    else
      # Use local active storage
      "#{ENV['OBLYK_API_URL']}#{Rails.application.routes.url_helpers.rails_representation_url(resize_attachement, only_path: true)}"
    end
  rescue StandardError
    nil
  end
end
