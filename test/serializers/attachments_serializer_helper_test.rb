# frozen_string_literal: true

require 'test_helper'

class AttachmentsSerializerHelperTest < ActiveSupport::TestCase
  setup do
    @area = areas(:foret_de_saou)
  end

  test 'It does not include attachments by default' do
    serializer = AreaSerializer.new(@area)
    serialization = JSON.parse(serializer.serializable_hash.to_json)

    assert_equal({}, serialization['data']['attributes']['attachments'])
  end

  test 'It includes requested attachments if they are defined in the serializer' do
    params = {
      include_attachments: {
        Area: [:avatar]
      }
    }
    serializer = AreaSerializer.new(@area, { params: params })
    serialization = JSON.parse(serializer.serializable_hash.to_json)

    assert serialization['data']['attributes']['attachments'].key?('avatar')
    avatar = serialization['data']['attributes']['attachments']['avatar']
    assert_kind_of Hash, avatar
    assert avatar.key?('attached')
    assert avatar.key?('attachment_type')
    assert_equal 'Area_picture', avatar['attachment_type']
  end

  test 'It handles missing or empty include_attachments param' do
    serializer = AreaSerializer.new(@area, { params: {} })
    serialization = JSON.parse(serializer.serializable_hash.to_json)
    assert_equal({}, serialization['data']['attributes']['attachments'])

    serializer = AreaSerializer.new(@area, { params: { include_attachments: {} } })
    serialization = JSON.parse(serializer.serializable_hash.to_json)
    assert_equal({}, serialization['data']['attributes']['attachments'])
  end

  test 'It ignores attachments for other types' do
    params = {
      include_attachments: {
        Crag: [:avatar]
      }
    }
    serializer = AreaSerializer.new(@area, { params: params })
    serialization = JSON.parse(serializer.serializable_hash.to_json)

    assert_equal({}, serialization['data']['attributes']['attachments'])
  end

  test 'It fails if requested attachment method is not defined' do
    params = {
      include_attachments: {
        Area: [:non_existent_attachment]
      }
    }
    serializer = AreaSerializer.new(@area, { params: params })

    assert_raises(NoMethodError) do
      serializer.serializable_hash
    end
  end
end
