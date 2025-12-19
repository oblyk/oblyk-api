# frozen_string_literal: true

module UploadVerification
  extend ActiveSupport::Concern

  private

  def verify_file(file, type = :image)
    content_types = case type
                    when :image
                      %w[image/jpeg image/png image/heic image/heif]
                    when :csv
                      %w[text/csv]
                    end
    errors = []
    errors << 'no_file' if file.class&.name != 'ActionDispatch::Http::UploadedFile'
    errors << 'file_wrong_format' if !defined?(file.content_type) || !content_types.include?(file.content_type)

    return true unless errors.size.positive?

    render json: { error: { base: errors } }, status: :unprocessable_entity
    false
  end
end
