# frozen_string_literal: true

require 'test_helper'

class ImageConverterServiceTest < ActiveSupport::TestCase
  setup do
    @tempfile = Tempfile.new(%w[test_image .png])
    @type = 'jpg'
    @service = ImageConverterService.new(tempfile: @tempfile, type: @type)
  end

  teardown do
    @tempfile.close
    @tempfile.unlink
  end

  test 'should initialize with correct attributes' do
    assert_equal @tempfile, @service.tempfile
    assert_equal @type, @service.type
  end

  test 'should use default type if not provided' do
    service = ImageConverterService.new(tempfile: @tempfile)
    assert_equal 'jpg', service.type
  end

  test 'should call image processing with correct parameters' do
    # On mock ImageProcessing::MiniMagick
    chain = Minitest::Mock.new
    chain.expect :convert, chain, [@type]
    chain.expect :call, 'converted_file_mock'

    ImageProcessing::MiniMagick.stub :source, lambda { |file|
      assert_equal @tempfile, file
      chain
    } do
      result = @service.call
      assert_equal 'converted_file_mock', result
    end

    assert_mock chain
  end
end
