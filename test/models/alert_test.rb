# frozen_string_literal: true

require 'test_helper'

class AlertTest < ActiveSupport::TestCase
  setup do
    @alert = alerts(:warning_alert)
    @crag = crags(:rocher_des_aures)
    @user = users(:normal_user)
  end

  test 'alert is valid' do
    assert @alert.valid?
  end

  test 'alert is invalid without description' do
    @alert.description = nil
    assert_not @alert.valid?
    assert_includes @alert.errors.keys, :description
  end

  test 'alert is invalid without alert_type' do
    @alert.alert_type = nil
    assert_not @alert.valid?
    assert_includes @alert.errors.keys, :alert_type
  end

  test 'alert is invalid with wrong alert_type' do
    @alert.alert_type = 'wrong_type'
    assert_not @alert.valid?
    assert_includes @alert.errors.keys, :alert_type
  end

  test 'alert is invalid with wrong alertable_type' do
    @alert.alertable_type = 'User'
    assert_not @alert.valid?
    assert_includes @alert.errors.keys, :alertable_type
  end

  test 'alerted_at is initialized before validation' do
    alert = Alert.new(
      description: 'New alert',
      alert_type: 'warning',
      alertable: @crag,
      user: @user
    )
    assert_nil alert.alerted_at
    alert.valid?
    assert_not_nil alert.alerted_at
  end

  test 'name returns formatted string' do
    assert_equal "warning - Crag/#{@crag.id}", @alert.name
  end

  test 'app_path returns formatted string' do
    assert_equal "/alerts/#{@alert.id}", @alert.app_path
  end

  test 'detail_to_json returns expected keys' do
    json = @alert.detail_to_json
    assert_equal @alert.id, json[:id]
    assert_equal @alert.description, json[:description]
    assert_equal @alert.alert_type, json[:alert_type]
    assert_equal @alert.alerted_at, json[:alerted_at]
    assert_equal 'Crag', json[:alertable_type]
    assert_not_nil json[:alertable]
    assert_not_nil json[:creator]
    assert_not_nil json[:history]
  end

  test 'publication_push! creates a publication for warning alerts' do
    assert_difference 'Publication.count', 1 do
      assert_difference 'PublicationAttachment.count', 1 do
        @alert.publication_push!
      end
    end
    publication = Publication.last
    assert_equal 'Crag', publication.publishable_type
    assert_equal @crag.id, publication.publishable_id
    assert_equal 'new_alert', publication.publishable_subject
  end

  test 'publication_push! does not create a publication for good alerts' do
    alert = alerts(:good_alert)
    assert_no_difference 'Publication.count' do
      alert.publication_push!
    end
  end

  test 'after_create callback triggers publication_push!' do
    assert_difference 'Publication.count', 1 do
      Alert.create!(
        description: 'Automatic publication',
        alert_type: 'warning',
        alertable: @crag,
        user: @user
      )
    end
  end

  test 'delegates latitude and longitude to alertable' do
    assert_equal @crag.latitude, @alert.latitude
    assert_equal @crag.longitude, @alert.longitude
  end
end
