# frozen_string_literal: true

require 'test_helper'

class PhotoSerializerTest < ActiveSupport::TestCase
  setup do
    @photo = Photo.new(
      user: users(:normal_user),
      illustrable: crags(:rocher_des_aures),
      description: 'A beautiful photo of Thabor',
      exif_model: 'iPhone 12',
      exif_make: 'Apple',
      source: 'Self',
      alt: 'Thabor cliff',
      copyright_by: true,
      copyright_nc: true,
      copyright_nd: false,
      likes_count: 5,
      created_at: Time.current,
      updated_at: Time.current
    )
    @photo.save
  end

  test 'It contains the basic attributes' do
    @photo.stub :photo_height, 100 do
      @photo.stub :photo_width, 200 do
        serializer = PhotoSerializer.new(@photo)
        serialization = JSON.parse(serializer.serializable_hash.to_json)
        assert_not_nil serialization['data']
        attributes = serialization['data']['attributes']

        assert_equal @photo.id, attributes['id']
        assert_equal @photo.description, attributes['description']
        assert_equal @photo.exif_model, attributes['exif_model']
        assert_equal @photo.exif_make, attributes['exif_make']
        assert_equal @photo.source, attributes['source']
        assert_equal @photo.alt, attributes['alt']
        assert_equal @photo.copyright_by, attributes['copyright_by']
        assert_equal @photo.copyright_nc, attributes['copyright_nc']
        assert_equal @photo.copyright_nd, attributes['copyright_nd']
        assert_equal 100, attributes['photo_height']
        assert_equal 200, attributes['photo_width']
        assert_equal @photo.likes_count, attributes['likes_count']
        assert_equal @photo.illustrable_type, attributes['illustrable_type']
        assert_equal @photo.illustrable_id, attributes['illustrable_id']
        assert_equal @photo.copy, attributes['copy']
        assert_equal @photo.app_path, attributes['app_path']
        assert_equal @photo.created_at.as_json, attributes['history']['created_at']
        assert_equal @photo.updated_at.as_json, attributes['history']['updated_at']
      end
    end
  end

  test 'It contains relationships' do
    @photo.stub :photo_height, 100 do
      @photo.stub :photo_width, 200 do
        serializer = PhotoSerializer.new(@photo)
        serialization = JSON.parse(serializer.serializable_hash.to_json)
        assert_not_nil serialization['data']

        if serialization['data']['relationships']
          relationships = serialization['data']['relationships']
          if relationships['illustrable'] && relationships['illustrable']['data']
            assert_equal @photo.illustrable_id, relationships['illustrable']['data']['id'].to_i
          end
          if relationships['user'] && relationships['user']['data']
            assert_equal @photo.user_id, relationships['user']['data']['id'].to_i
          end
        end

        attributes = serialization['data']['attributes']
        assert_equal @photo.illustrable_id, attributes['illustrable_id']
        assert_equal @photo.illustrable_type, attributes['illustrable_type']
      end
    end
  end

  test 'It contains attachments when requested' do
    @photo.stub :photo_height, 100 do
      @photo.stub :photo_width, 200 do
        mock_attachment = { url: 'http://test.host/picture.jpg' }

        PhotoSerializer.stub :picture_attachment, mock_attachment do
          serializer = PhotoSerializer.new(@photo, params: { include_attachments: { Photo: [:picture] } })
          serialization = JSON.parse(serializer.serializable_hash.to_json)
          attributes = serialization['data']['attributes']

          assert_not_nil attributes['attachments']
          assert_equal 'http://test.host/picture.jpg', attributes['attachments']['picture']['url']
        end
      end
    end
  end
end
