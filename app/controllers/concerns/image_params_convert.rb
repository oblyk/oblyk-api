# frozen_string_literal: true

module ImageParamsConvert
  extend ActiveSupport::Concern

  private

  def convert_image_on_params(keys)
    attaching_picture = params.dig(*keys)
    return attaching_picture if attaching_picture.blank?
    return attaching_picture unless %w[image/heif image/heic].include?(attaching_picture.content_type)

    tempfile = ImageConverterService.new(tempfile: attaching_picture.tempfile, type: 'jpg').call
    file_name = "#{attaching_picture.original_filename.split('.').first}.jpg"
    ActionDispatch::Http::UploadedFile.new(
      {
        filename: file_name,
        tempfile: tempfile,
        type: 'image/jpg',
        head: attaching_picture.headers
                               .gsub(attaching_picture.original_filename, file_name)
                               .gsub(attaching_picture.content_type, 'image/jpg')
      }
    )
  end
end
