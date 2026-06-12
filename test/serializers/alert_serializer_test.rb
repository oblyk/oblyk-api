# frozen_string_literal: true

require 'test_helper'

class AlertSerializerTest < ActiveSupport::TestCase
  setup do
    @alert = alerts(:warning_alert)
    @serializer = AlertSerializer.new(@alert)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @alert.id, attributes['id']
    assert_equal @alert.app_path, attributes['app_path']
    assert_equal @alert.description, attributes['description']
    assert_equal @alert.alert_type, attributes['alert_type']
    assert_equal @alert.alerted_at.as_json, attributes['alerted_at']
    assert_equal @alert.alertable_type, attributes['alertable_type']
    assert_equal @alert.alertable_id, attributes['alertable_id']
  end

  test 'It contains the history attribute' do
    history = @serialization['data']['attributes']['history']
    assert_equal @alert.created_at.as_json, history['created_at']
    assert_equal @alert.updated_at.as_json, history['updated_at']
  end

  test 'It may include alertable if specified' do
    serializer = AlertSerializer.new(@alert, { include: [:alertable] })
    serialization = JSON.parse(serializer.serializable_hash.to_json)

    assert_not_nil serialization['included']
    alertable_include = serialization['included'].find { |inc| inc['type'] == 'crag' }
    assert_not_nil alertable_include
    assert_equal @alert.alertable_id.to_s, alertable_include['id']
  end
end
