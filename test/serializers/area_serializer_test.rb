# frozen_string_literal: true

require 'test_helper'

class AreaSerializerTest < ActiveSupport::TestCase
  setup do
    @area = areas(:foret_de_saou)
    @area.valid?
    @area.save
    @serializer = AreaSerializer.new(@area)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @area.id, attributes['id']
    assert_equal @area.name, attributes['name']
    assert_equal @area.slug_name, attributes['slug_name']
  end

  test 'It contains the history attribute' do
    history = @serialization['data']['attributes']['history']
    assert_equal @area.created_at.as_json, history['created_at']
    assert_equal @area.updated_at.as_json, history['updated_at']
  end

  test 'It may include crags if specified' do
    serializer = AreaSerializer.new(@area, { include: [:crags] })
    serialization = JSON.parse(serializer.serializable_hash.to_json)

    assert_not_nil serialization['included']
    crag_include = serialization['included'].find { |inc| inc['type'] == 'crag' }
    assert_not_nil crag_include
  end

  test 'It may include attachments if specified' do
    serializer = AreaSerializer.new(@area, { params: { include_attachments: { Area: [:avatar] } } })
    serialization = JSON.parse(serializer.serializable_hash.to_json)

    assert serialization['data']['attributes'].key?('attachments')
    assert serialization['data']['attributes']['attachments'].key?('avatar')
  end

  test 'avatar_attachment returns correct structure' do
    avatar = AreaSerializer.avatar_attachment(@area)
    assert_kind_of Hash, avatar
    assert avatar.key?(:attached)
    assert avatar.key?(:attachment_type)
    assert_equal 'Area_picture', avatar[:attachment_type]
    assert avatar.key?(:variant_path)
  end
end
