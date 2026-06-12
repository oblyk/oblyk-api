# frozen_string_literal: true

require 'test_helper'

class PublicationAuthorSerializerTest < ActiveSupport::TestCase
  setup do
    @user = users(:normal_user)
    @serializer = PublicationAuthorSerializer.new(@user)
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
    assert_equal @user.full_name, attributes['name']
  end
end
