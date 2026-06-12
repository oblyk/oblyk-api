# frozen_string_literal: true

require 'test_helper'

module CdnCgi
  class ImagesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @crag = crags(:rocher_des_aures)
      png_1x1 = [
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
        0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
        0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
        0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
        0x42, 0x60, 0x82
      ].pack('C*')
      @crag.static_map.attach(
        io: StringIO.new(png_1x1),
        filename: 'test.png',
        content_type: 'image/png'
      )
      @attachment = @crag.static_map.attachment
      @blob = @attachment.blob
      ENV['OBLYK_API_URL'] = 'http://test.host'
    end

    test 'should redirect to original image when no fit option is provided' do
      get "/cdn-cgi/image/quality=90/#{@blob.key}"

      assert_response :redirect
      assert_redirected_to "#{ENV['OBLYK_API_URL']}#{Rails.application.routes.url_helpers.polymorphic_url(@attachment, only_path: true)}"
    end

    test 'should handle multiple options and use quality' do
      get "/cdn-cgi/image/fit=scale-down,width=50,height=50,quality=75/#{@blob.key}"
      assert_response :redirect
      assert_match %r{rails/active_storage/representations}, response.redirect_url
    end

    test 'should redirect to scaled-down image' do
      get "/cdn-cgi/image/fit=scale-down,width=100,height=100/#{@blob.key}"

      assert_response :redirect
      assert_match %r{rails/active_storage/representations}, response.redirect_url
    end

    test 'should redirect to cropped image' do
      get "/cdn-cgi/image/fit=crop,width=100,height=100/#{@blob.key}"

      assert_response :redirect
      assert_match %r{rails/active_storage/representations}, response.redirect_url
    end

    test 'should use default quality if not provided' do
      get "/cdn-cgi/image/fit=scale-down,width=100,height=100/#{@blob.key}"
      assert_response :redirect
    end

    test 'should return 404 (or error) if attachment is not found' do
      assert_raises(ArgumentError) do
        get '/cdn-cgi/image/quality=90/non-existent-key'
      end
    end
  end
end
