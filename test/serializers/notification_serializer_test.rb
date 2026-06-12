# frozen_string_literal: true

require 'test_helper'

class NotificationSerializerTest < ActiveSupport::TestCase
  setup do
    @notification = notifications(:new_message_notif)
    @serializer = NotificationSerializer.new(@notification)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @notification.id, attributes['id']
    assert_equal @notification.notification_type, attributes['notification_type']
    assert_equal @notification.notifiable_type, attributes['notifiable_type']
    assert_equal @notification.notifiable_id, attributes['notifiable_id']
    assert_equal @notification.posted_at.as_json, attributes['posted_at']
    if @notification.read_at.nil?
      assert_nil attributes['read_at']
    else
      assert_equal @notification.read_at.as_json, attributes['read_at']
    end
    assert_equal @notification.name, attributes['name']
    assert_equal @notification.app_path, attributes['app_path']
    assert_equal @notification.created_at.as_json, attributes['history']['created_at']
    assert_equal @notification.updated_at.as_json, attributes['history']['updated_at']
  end

  test 'It contains relationships' do
    relationships = @serialization['data']['relationships']
    assert_not_nil relationships['notifiable']
    assert_equal @notification.notifiable_id, relationships['notifiable']['data']['id'].to_i
    assert_equal @notification.notifiable_type, relationships['notifiable']['data']['type'].underscore.camelize
  end
end
