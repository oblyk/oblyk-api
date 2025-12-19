# frozen_string_literal: true

class ImageConverterService
  attr_accessor :type, :tempfile

  def initialize(tempfile:, type: 'jpg')
    self.tempfile = tempfile
    self.type = type
  end

  def call
    ImageProcessing::MiniMagick.source(tempfile)
                               .convert(type)
                               .call
  end
end
