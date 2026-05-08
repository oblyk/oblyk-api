# frozen_string_literal: true

require 'test_helper'

class UserSerializerTest < ActiveSupport::TestCase
  setup do
    @user = users(:normal_user)
    @user.save # Force callbacks to generate UUIDs, slug names, etc.
    @serializer = UserSerializer.new(@user)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @user.id, attributes['id']
    assert_equal @user.uuid, attributes['uuid']
    assert_equal @user.slug_name, attributes['slug_name']
    assert_equal @user.first_name, attributes['first_name']
    assert_equal @user.full_name, attributes['full_name']
    assert_equal @user.app_path, attributes['app_path']
  end

  test 'It contains the "name" attribute, which corresponds to "full_name"' do
    attributes = @serialization['data']['attributes']
    assert_equal @user.full_name, attributes['name']
  end

  test 'it may include attachments if specified' do
    serializer = UserSerializer.new(@user, { params: { include_attachments: { User: [:avatar] } } })
    serialization = JSON.parse(serializer.serializable_hash.to_json)

    assert serialization['data']['attributes'].key?('attachments')
  end
end
