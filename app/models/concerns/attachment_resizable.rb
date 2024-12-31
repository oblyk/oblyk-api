# frozen_string_literal: true

module AttachmentResizable
  extend ActiveSupport::Concern

  def attachment_object(attachment, attachement_type = nil)
    variant_path = nil
    attachment_attached = false
    attachement_type = attachement_type.presence || "#{attachment.record.class.name}_#{attachment.name}"
    if attachment.attached?
      storage_domaine = ENV.fetch('IMAGES_STORAGE_DOMAINE', ENV['OBLYK_API_URL'])
      variant_path = "#{storage_domaine}/cdn-cgi/image/:variant/#{attachment.blob.key}"
      attachment_attached = true
    end
    {
      attached: attachment_attached,
      attachment_type: attachement_type,
      variant_path: variant_path
    }
  rescue StandardError
    attachement_type = attachement_type.presence || "#{attachment.record.class.name}_#{attachment.name}"
    {
      attached: false,
      attachment_type: attachement_type,
      variant_path: nil
    }
  end

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
