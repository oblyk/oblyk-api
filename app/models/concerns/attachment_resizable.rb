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

  def convert_image(attachment)
    return unless attachment.attached?

    attachment.open(tmpdir: '/tmp') do |file|
      image = ImageProcessing::MiniMagick.source(file.path)
      result = image.convert!('jpg')
      attachment.attach(io: File.open(result.path), filename: "picture-#{SecureRandom.alphanumeric(12)}.jpg", content_type: 'image/jpg')
    end
  end
end
